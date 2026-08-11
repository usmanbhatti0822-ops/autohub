import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Booking, BookingStatus } from './entities/booking.entity';
import { RentalsService } from '../rentals/rentals.service';
import { CreateBookingDto } from './dto/booking.dto';

const ALLOWED_TRANSITIONS: Record<BookingStatus, BookingStatus[]> = {
  [BookingStatus.REQUESTED]: [BookingStatus.CONFIRMED, BookingStatus.CANCELLED],
  [BookingStatus.CONFIRMED]: [BookingStatus.ONGOING, BookingStatus.CANCELLED],
  [BookingStatus.ONGOING]: [BookingStatus.COMPLETED],
  [BookingStatus.COMPLETED]: [],
  [BookingStatus.CANCELLED]: [],
};

@Injectable()
export class BookingsService {
  constructor(
    @InjectRepository(Booking) private repo: Repository<Booking>,
    private rentalsService: RentalsService,
  ) {}

  async create(renterId: string, dto: CreateBookingDto): Promise<Booking> {
    const vehicle = await this.rentalsService.findOne(dto.vehicleId);
    const start = new Date(dto.startDate);
    const end = new Date(dto.endDate);

    if (start >= end) throw new BadRequestException('endDate must be after startDate');
    if (start < new Date()) throw new BadRequestException('startDate cannot be in the past');

    const available = await this.rentalsService.isAvailable(vehicle.id, start, end);
    if (!available) throw new BadRequestException('Vehicle is not available for these dates');

    const days = Math.ceil((end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24));
    const totalPrice = days * Number(vehicle.dailyRate);

    const booking = this.repo.create({
      vehicleId: vehicle.id,
      renterId,
      startDate: start,
      endDate: end,
      totalPrice,
      securityDeposit: vehicle.securityDeposit,
      withDriver: dto.withDriver ?? false,
      status: BookingStatus.REQUESTED,
    });
    return this.repo.save(booking);
  }

  async findOne(id: string): Promise<Booking> {
    const booking = await this.repo.findOne({
      where: { id },
      relations: { vehicle: true, renter: true },
    });
    if (!booking) throw new NotFoundException('Booking not found');
    return booking;
  }

  async myBookings(renterId: string): Promise<Booking[]> {
    return this.repo.find({
      where: { renterId },
      relations: { vehicle: true },
      order: { createdAt: 'DESC' },
    });
  }

  /** Bookings for vehicles owned by this user (owner-side view). */
  async bookingsForOwner(ownerId: string): Promise<Booking[]> {
    return this.repo
      .createQueryBuilder('booking')
      .leftJoinAndSelect('booking.vehicle', 'vehicle')
      .leftJoinAndSelect('booking.renter', 'renter')
      .where('vehicle.ownerId = :ownerId', { ownerId })
      .orderBy('booking.createdAt', 'DESC')
      .getMany();
  }

  private async transition(
    id: string,
    requesterId: string,
    next: BookingStatus,
    checkOwnership: 'renter' | 'owner' | 'either',
  ): Promise<Booking> {
    const booking = await this.findOne(id);

    if (checkOwnership === 'renter' && booking.renterId !== requesterId) {
      throw new ForbiddenException('Not your booking');
    }
    if (checkOwnership === 'owner' && booking.vehicle.ownerId !== requesterId) {
      throw new ForbiddenException('Not your vehicle');
    }
    if (
      checkOwnership === 'either' &&
      booking.renterId !== requesterId &&
      booking.vehicle.ownerId !== requesterId
    ) {
      throw new ForbiddenException('Not part of this booking');
    }

    if (!ALLOWED_TRANSITIONS[booking.status].includes(next)) {
      throw new BadRequestException(
        `Cannot move booking from ${booking.status} to ${next}`,
      );
    }

    booking.status = next;
    return this.repo.save(booking);
  }

  /** Owner confirms a requested booking. */
  confirm(id: string, ownerId: string) {
    return this.transition(id, ownerId, BookingStatus.CONFIRMED, 'owner');
  }

  /** Either party marks the rental as started (e.g. at pickup). */
  startRental(id: string, requesterId: string) {
    return this.transition(id, requesterId, BookingStatus.ONGOING, 'either');
  }

  /** Either party marks the rental as completed (e.g. at return). */
  complete(id: string, requesterId: string) {
    return this.transition(id, requesterId, BookingStatus.COMPLETED, 'either');
  }

  async cancel(id: string, requesterId: string, reason?: string) {
    const booking = await this.transition(id, requesterId, BookingStatus.CANCELLED, 'either');
    booking.cancellationReason = reason ?? null;
    return this.repo.save(booking);
  }

  async addPickupPhotos(id: string, requesterId: string, photoUrls: string[]) {
    const booking = await this.findOne(id);
    if (booking.renterId !== requesterId && booking.vehicle.ownerId !== requesterId) {
      throw new ForbiddenException('Not part of this booking');
    }
    booking.pickupPhotoUrls = photoUrls;
    return this.repo.save(booking);
  }

  async addReturnPhotos(id: string, requesterId: string, photoUrls: string[]) {
    const booking = await this.findOne(id);
    if (booking.renterId !== requesterId && booking.vehicle.ownerId !== requesterId) {
      throw new ForbiddenException('Not part of this booking');
    }
    booking.returnPhotoUrls = photoUrls;
    return this.repo.save(booking);
  }
}
