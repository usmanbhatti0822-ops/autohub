import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Review } from './entities/review.entity';
import { CreateReviewDto } from './dto/create-review.dto';

@Injectable()
export class ReviewsService {
  constructor(@InjectRepository(Review) private repo: Repository<Review>) {}

  async create(authorId: string, dto: CreateReviewDto): Promise<Review> {
    const review = this.repo.create({ ...dto, authorId });
    return this.repo.save(review);
  }

  async forUser(subjectId: string): Promise<{ reviews: Review[]; average: number }> {
    const reviews = await this.repo.find({
      where: { subjectId },
      relations: { author: true },
      order: { createdAt: 'DESC' },
    });
    const average = reviews.length
      ? reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length
      : 0;
    return { reviews, average: Math.round(average * 10) / 10 };
  }
}
