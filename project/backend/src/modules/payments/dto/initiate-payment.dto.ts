import { IsEnum, IsNumber, IsOptional, IsString, Min } from 'class-validator';
import { PaymentGateway } from '../entities/payment-order.entity';

export class InitiatePaymentDto {
  @IsNumber()
  @Min(1)
  amount: number;

  @IsEnum(PaymentGateway)
  gateway: PaymentGateway;

  @IsOptional()
  @IsString()
  relatedBookingId?: string;
}
