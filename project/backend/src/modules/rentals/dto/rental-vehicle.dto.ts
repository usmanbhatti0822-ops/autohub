import { IsBoolean, IsEnum, IsInt, IsNumber, IsNumberString, IsOptional, IsString, Min } from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';
import { TransmissionType, FuelType, VehicleCategory } from '../../listings/entities/listing.entity';

export class CreateRentalVehicleDto {
  @IsString()
  make: string;

  @IsString()
  model: string;

  @IsInt()
  @Min(1990)
  year: number;

  @IsEnum(TransmissionType)
  transmission: TransmissionType;

  @IsEnum(FuelType)
  fuelType: FuelType;

  @IsOptional()
  @IsEnum(VehicleCategory)
  category?: VehicleCategory;

  @IsOptional()
  @IsInt()
  @Min(1)
  seats?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  doors?: number;

  @IsOptional()
  features?: string[];

  @IsString()
  city: string;

  @IsString()
  pickupLocation: string;

  @IsNumber()
  @Min(0)
  dailyRate: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  securityDeposit?: number;

  @IsOptional()
  @IsBoolean()
  driverAvailable?: boolean;

  @IsOptional()
  photoUrls?: string[];

  @IsOptional()
  @IsString()
  description?: string;
}

export class UpdateRentalVehicleDto extends PartialType(CreateRentalVehicleDto) {}

export class SearchRentalVehiclesDto {
  @IsOptional()
  @IsString()
  city?: string;

  @IsOptional()
  @IsString()
  make?: string;

  @IsOptional()
  @IsEnum(TransmissionType)
  transmission?: TransmissionType;

  @IsOptional()
  @IsEnum(VehicleCategory)
  category?: VehicleCategory;

  @IsOptional()
  @IsNumberString()
  minPrice?: string;

  @IsOptional()
  @IsNumberString()
  maxPrice?: string;

  @IsOptional()
  @IsString()
  sortBy?: 'newest' | 'price_asc' | 'price_desc';

  @IsOptional()
  startDate?: string;

  @IsOptional()
  endDate?: string;

  @IsOptional()
  page?: string;

  @IsOptional()
  limit?: string;
}
