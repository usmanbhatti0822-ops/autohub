import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { BookingsService } from './bookings.service';
import { CancelBookingDto, ChecklistPhotosDto, CreateBookingDto } from './dto/booking.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@Controller('bookings')
@UseGuards(JwtAuthGuard)
export class BookingsController {
  constructor(private bookingsService: BookingsService) {}

  @Post()
  create(@CurrentUser() user: { userId: string }, @Body() dto: CreateBookingDto) {
    return this.bookingsService.create(user.userId, dto);
  }

  @Get('mine')
  myBookings(@CurrentUser() user: { userId: string }) {
    return this.bookingsService.myBookings(user.userId);
  }

  @Get('owner')
  ownerBookings(@CurrentUser() user: { userId: string }) {
    return this.bookingsService.bookingsForOwner(user.userId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.bookingsService.findOne(id);
  }

  @Patch(':id/confirm')
  confirm(@Param('id') id: string, @CurrentUser() user: { userId: string }) {
    return this.bookingsService.confirm(id, user.userId);
  }

  @Patch(':id/start')
  start(@Param('id') id: string, @CurrentUser() user: { userId: string }) {
    return this.bookingsService.startRental(id, user.userId);
  }

  @Patch(':id/complete')
  complete(@Param('id') id: string, @CurrentUser() user: { userId: string }) {
    return this.bookingsService.complete(id, user.userId);
  }

  @Patch(':id/cancel')
  cancel(
    @Param('id') id: string,
    @CurrentUser() user: { userId: string },
    @Body() dto: CancelBookingDto,
  ) {
    return this.bookingsService.cancel(id, user.userId, dto.reason);
  }

  @Patch(':id/pickup-photos')
  pickupPhotos(
    @Param('id') id: string,
    @CurrentUser() user: { userId: string },
    @Body() dto: ChecklistPhotosDto,
  ) {
    return this.bookingsService.addPickupPhotos(id, user.userId, dto.photoUrls);
  }

  @Patch(':id/return-photos')
  returnPhotos(
    @Param('id') id: string,
    @CurrentUser() user: { userId: string },
    @Body() dto: ChecklistPhotosDto,
  ) {
    return this.bookingsService.addReturnPhotos(id, user.userId, dto.photoUrls);
  }
}
