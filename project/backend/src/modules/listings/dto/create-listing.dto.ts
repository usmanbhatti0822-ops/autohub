import { IsEnum, IsInt, IsNumber, IsOptional, IsString, Min, MaxLength } from 'class-validator';
import { TransmissionType, FuelType, VehicleCategory } from '../entities/listing.entity';

export class CreateListingDto {
  @IsString()
  make: string;

  @IsString()
  model: string;

  @IsInt()
  @Min(1990)
  year: number;

  @IsOptional()
  @IsString()
  variant?: string;

  @IsInt()
  @Min(0)
  mileageKm: number;

  @IsNumber()
  @Min(0)
  price: number;

  @IsString()
  city: string;

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

  @IsOptional()
  photoUrls?: string[];

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  description?: string;
}
