import { IsBoolean, IsDateString, IsOptional, IsString } from 'class-validator';

export class CreateBookingDto {
  @IsString()
  vehicleId: string;

  @IsDateString()
  startDate: string;

  @IsDateString()
  endDate: string;

  @IsOptional()
  @IsBoolean()
  withDriver?: boolean;
}

export class CancelBookingDto {
  @IsOptional()
  @IsString()
  reason?: string;
}

export class ChecklistPhotosDto {
  photoUrls: string[];
}
