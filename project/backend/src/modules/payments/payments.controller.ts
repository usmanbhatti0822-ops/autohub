import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { InitiatePaymentDto } from './dto/initiate-payment.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@Controller('payments')
export class PaymentsController {
  constructor(private paymentsService: PaymentsService) {}

  @Post('initiate')
  @UseGuards(JwtAuthGuard)
  initiate(@CurrentUser() user: { userId: string }, @Body() dto: InitiatePaymentDto) {
    return this.paymentsService.initiate(user.userId, dto);
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard)
  findOne(@Param('id') id: string) {
    return this.paymentsService.findOne(id);
  }

  /**
   * Dev-only manual settlement endpoint until a real gateway webhook is
   * wired (see PaymentsService header comment). Remove/replace with the
   * real signed webhook handler before production.
   */
  @Post(':id/dev-settle')
  devSettle(
    @Param('id') id: string,
    @Body() body: { success: boolean; ownerId?: string; gatewayReference?: string },
  ) {
    return this.paymentsService.markResult(id, body.success, body.gatewayReference, body.ownerId);
  }
}
