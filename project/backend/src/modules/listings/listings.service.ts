import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CarListing, ListingStatus } from './entities/listing.entity';
import { CreateListingDto } from './dto/create-listing.dto';
import { UpdateListingDto, SearchListingsDto } from './dto/update-listing.dto';

@Injectable()
export class ListingsService {
  constructor(
    @InjectRepository(CarListing) private repo: Repository<CarListing>,
  ) {}

  async create(sellerId: string, dto: CreateListingDto): Promise<CarListing> {
    const listing = this.repo.create({
      ...dto,
      sellerId,
      status: ListingStatus.PENDING, // goes live after admin approval
    });
    return this.repo.save(listing);
  }

  async search(query: SearchListingsDto) {
    const page = Number(query.page) || 1;
    const limit = Math.min(Number(query.limit) || 20, 50);

    const qb = this.repo
      .createQueryBuilder('listing')
      .leftJoinAndSelect('listing.seller', 'seller')
      .where('listing.status = :status', { status: ListingStatus.APPROVED });

    if (query.make) qb.andWhere('listing.make ILIKE :make', { make: `%${query.make}%` });
    if (query.model) qb.andWhere('listing.model ILIKE :model', { model: `%${query.model}%` });
    if (query.city) qb.andWhere('listing.city ILIKE :city', { city: `%${query.city}%` });
    if (query.transmission) qb.andWhere('listing.transmission = :t', { t: query.transmission });
    if (query.fuelType) qb.andWhere('listing.fuelType = :f', { f: query.fuelType });
    if (query.category) qb.andWhere('listing.category = :c', { c: query.category });
    if (query.minPrice) qb.andWhere('listing.price >= :minPrice', { minPrice: query.minPrice });
    if (query.maxPrice) qb.andWhere('listing.price <= :maxPrice', { maxPrice: query.maxPrice });

    if (query.sortBy === 'price_asc') qb.orderBy('listing.price', 'ASC');
    else if (query.sortBy === 'price_desc') qb.orderBy('listing.price', 'DESC');
    else qb.orderBy('listing.createdAt', 'DESC');

    qb.skip((page - 1) * limit).take(limit);

    const [items, total] = await qb.getManyAndCount();
    return { items, total, page, limit };
  }

  async findOne(id: string): Promise<CarListing> {
    const listing = await this.repo.findOne({ where: { id }, relations: { seller: true } });
    if (!listing) throw new NotFoundException('Listing not found');
    return listing;
  }

  async update(id: string, userId: string, dto: UpdateListingDto): Promise<CarListing> {
    const listing = await this.findOne(id);
    if (listing.sellerId !== userId) {
      throw new ForbiddenException('You do not own this listing');
    }
    Object.assign(listing, dto);
    return this.repo.save(listing);
  }

  async remove(id: string, userId: string): Promise<void> {
    const listing = await this.findOne(id);
    if (listing.sellerId !== userId) {
      throw new ForbiddenException('You do not own this listing');
    }
    await this.repo.remove(listing);
  }

  async myListings(sellerId: string): Promise<CarListing[]> {
    return this.repo.find({ where: { sellerId }, order: { createdAt: 'DESC' } });
  }

  // --- Admin ---
  async setStatus(id: string, status: ListingStatus): Promise<CarListing> {
    const listing = await this.findOne(id);
    listing.status = status;
    return this.repo.save(listing);
  }
}
