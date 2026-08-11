import { Controller, Get, UseGuards } from '@nestjs/common';
import { WalletService } from './wallet.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@Controller('wallet')
@UseGuards(JwtAuthGuard)
export class WalletController {
  constructor(private walletService: WalletService) {}

  @Get('balance')
  async balance(@CurrentUser() user: { userId: string }) {
    return { balance: await this.walletService.balance(user.userId) };
  }

  @Get('history')
  history(@CurrentUser() user: { userId: string }) {
    return this.walletService.history(user.userId);
  }
}
