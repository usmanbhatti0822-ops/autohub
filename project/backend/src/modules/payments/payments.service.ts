import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PaymentGateway, PaymentOrder, PaymentStatus } from './entities/payment-order.entity';
import { InitiatePaymentDto } from './dto/initiate-payment.dto';
import { WalletService } from '../wallet/wallet.service';

/**
 * NOTE ON GATEWAY INTEGRATION
 * ---------------------------
 * This module intentionally stops short of calling real JazzCash/Easypaisa
 * APIs, because that requires merchant credentials (Merchant ID, Password,
 * Integrity Salt for JazzCash; Store ID + Hash key for Easypaisa) that only
 * you can obtain from those providers. The structure below is where that
 * integration plugs in:
 *
 *   1. `initiate()` — build the redirect/checkout payload per the gateway's
 *      docs (JazzCash: HTTP POST redirect with a hashed secure signature;
 *      Easypaisa: similar signed-redirect flow) and return the redirect URL
 *      to the client instead of the current `simulateSuccessUrl` placeholder.
 *   2. `handleWebhook()` — verify the gateway's callback signature, then
 *      mark the order success/failed. Currently this is exposed as a plain
 *      endpoint for manual testing (see payments.controller.ts).
 *
 * Once you have merchant credentials, tell me and I'll wire the real
 * request signing for whichever gateway you want first.
 */
@Injectable()
export class PaymentsService {
  constructor(
    @InjectRepository(PaymentOrder) private repo: Repository<PaymentOrder>,
    private walletService: WalletService,
  ) {}

  async initiate(payerId: string, dto: InitiatePaymentDto) {
    const order = this.repo.create({
      payerId,
      amount: dto.amount,
      gateway: dto.gateway,
      relatedBookingId: dto.relatedBookingId,
      status: PaymentStatus.PENDING,
    });
    await this.repo.save(order);

    if (dto.gateway === PaymentGateway.CASH_ON_PICKUP) {
      // No online step needed — mark pending until confirmed at pickup.
      return { orderId: order.id, status: order.status, checkoutUrl: null };
    }

    // TODO: replace with the real signed redirect URL from the gateway.
    return {
      orderId: order.id,
      status: order.status,
      checkoutUrl: `https://sandbox.example-gateway.test/pay/${order.id}`,
      note: 'Placeholder checkout URL — see PaymentsService header comment.',
    };
  }

  /** Called by the gateway webhook (or manually in dev) to settle an order. */
  async markResult(orderId: string, success: boolean, gatewayReference?: string, ownerId?: string) {
    const order = await this.repo.findOne({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Payment order not found');

    order.status = success ? PaymentStatus.SUCCESS : PaymentStatus.FAILED;
    order.gatewayReference = gatewayReference ?? null;
    await this.repo.save(order);

    if (success && ownerId) {
      // Credit the seller/owner's wallet, minus platform commission (10% example).
      const commission = Number(order.amount) * 0.1;
      const net = Number(order.amount) - commission;
      await this.walletService.credit(ownerId, net, `Payment for order ${order.id}`, order.relatedBookingId);
      await this.walletService.recordCommission(ownerId, commission, order.relatedBookingId);
    }

    return order;
  }

  async findOne(id: string): Promise<PaymentOrder> {
    const order = await this.repo.findOne({ where: { id } });
    if (!order) throw new NotFoundException('Payment order not found');
    return order;
  }
}
