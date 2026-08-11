import { IsEnum, IsInt, IsOptional, IsString, Max, Min } from 'class-validator';
import { ReviewType } from '../entities/review.entity';

export class CreateReviewDto {
  @IsString()
  subjectId: string;

  @IsEnum(ReviewType)
  type: ReviewType;

  @IsInt()
  @Min(1)
  @Max(5)
  rating: number;

  @IsOptional()
  @IsString()
  comment?: string;

  @IsOptional()
  @IsString()
  relatedBookingId?: string;

  @IsOptional()
  @IsString()
  relatedListingId?: string;
}
