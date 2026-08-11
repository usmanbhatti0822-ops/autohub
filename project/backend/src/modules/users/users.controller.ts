import { Body, Controller, Get, Patch, UseGuards } from '@nestjs/common';
import { UsersService, sanitizeUser } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@Controller('users')
export class UsersController {
  constructor(private usersService: UsersService) {}

  @UseGuards(JwtAuthGuard)
  @Get('me')
  async getMe(@CurrentUser() user: { userId: string }) {
    return sanitizeUser(await this.usersService.findById(user.userId));
  }

  @UseGuards(JwtAuthGuard)
  @Patch('me')
  async updateMe(@CurrentUser() user: { userId: string }, @Body() dto: UpdateUserDto) {
    return sanitizeUser(await this.usersService.update(user.userId, dto));
  }
}
