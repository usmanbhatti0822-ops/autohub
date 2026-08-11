import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual, MoreThanOrEqual } from 'typeorm';
import { RentalVehicle, RentalVehicleStatus } from './entities/rental-vehicle.entity';
import { Booking, BookingStatus } from '../bookings/entities/booking.entity';
import {
  CreateRentalVehicleDto,
  SearchRentalVehiclesDto,
  UpdateRentalVehicleDto,
} from './dto/rental-vehicle.dto';

@Injectable()
export class RentalsService {
  constructor(
    @InjectRepository(RentalVehicle) private repo: Repository<RentalVehicle>,
    @InjectRepository(Booking) private bookingsRepo: Repository<Booking>,
  ) {}

  async create(ownerId: string, dto: CreateRentalVehicleDto): Promise<RentalVehicle> {
    const vehicle = this.repo.create({
      ...dto,
      ownerId,
      status: RentalVehicleStatus.PENDING,
    });
    return this.repo.save(vehicle);
  }

  async search(query: SearchRentalVehiclesDto) {
    const page = Number(query.page) || 1;
    const limit = Math.min(Number(query.limit) || 20, 50);

    const qb = this.repo
      .createQueryBuilder('vehicle')
      .leftJoinAndSelect('vehicle.owner', 'owner')
      .where('vehicle.status = :status', { status: RentalVehicleStatus.APPROVED });

    if (query.city) qb.andWhere('vehicle.city ILIKE :city', { city: `%${query.city}%` });
    if (query.make) qb.andWhere('vehicle.make ILIKE :make', { make: `%${query.make}%` });
    if (query.transmission)
      qb.andWhere('vehicle.transmission = :t', { t: query.transmission });
    if (query.category) qb.andWhere('vehicle.category = :c', { c: query.category });
    if (query.minPrice) qb.andWhere('vehicle.dailyRate >= :minPrice', { minPrice: query.minPrice });
    if (query.maxPrice) qb.andWhere('vehicle.dailyRate <= :maxPrice', { maxPrice: query.maxPrice });

    // Exclude vehicles with an overlapping active booking for the requested range.
    if (query.startDate && query.endDate) {
      qb.andWhere(
        `vehicle.id NOT IN (
          SELECT b."vehicleId" FROM bookings b
          WHERE b.status IN ('requested', 'confirmed', 'ongoing')
          AND b."startDate" <= :endDate AND b."endDate" >= :startDate
        )`,
        { startDate: query.startDate, endDate: query.endDate },
      );
    }

    if (query.sortBy === 'price_asc') qb.orderBy('vehicle.dailyRate', 'ASC');
    else if (query.sortBy === 'price_desc') qb.orderBy('vehicle.dailyRate', 'DESC');
    else qb.orderBy('vehicle.createdAt', 'DESC');

    qb.skip((page - 1) * limit).take(limit);

    const [items, total] = await qb.getManyAndCount();
    return { items, total, page, limit };
  }

  async findOne(id: string): Promise<RentalVehicle> {
    const vehicle = await this.repo.findOne({ where: { id }, relations: { owner: true } });
    if (!vehicle) throw new NotFoundException('Rental vehicle not found');
    return vehicle;
  }

  /** True if the vehicle has no active booking overlapping the given range. */
  async isAvailable(vehicleId: string, startDate: Date, endDate: Date): Promise<boolean> {
    const overlapping = await this.bookingsRepo
      .createQueryBuilder('b')
      .where('b.vehicleId = :vehicleId', { vehicleId })
      .andWhere('b.status IN (:...statuses)', {
        statuses: [BookingStatus.REQUESTED, BookingStatus.CONFIRMED, BookingStatus.ONGOING],
      })
      .andWhere('b.startDate <= :endDate AND b.endDate >= :startDate', {
        startDate,
        endDate,
      })
      .getCount();
    return overlapping === 0;
  }

  async update(id: string, ownerId: string, dto: UpdateRentalVehicleDto): Promise<RentalVehicle> {
    const vehicle = await this.findOne(id);
    if (vehicle.ownerId !== ownerId) throw new ForbiddenException('Not your vehicle');
    Object.assign(vehicle, dto);
    return this.repo.save(vehicle);
  }

  async myVehicles(ownerId: string): Promise<RentalVehicle[]> {
    return this.repo.find({ where: { ownerId }, order: { createdAt: 'DESC' } });
  }

  async setStatus(id: string, status: RentalVehicleStatus): Promise<RentalVehicle> {
    const vehicle = await this.findOne(id);
    vehicle.status = status;
    return this.repo.save(vehicle);
  }
}
