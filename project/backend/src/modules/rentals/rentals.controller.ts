import { Body, Controller, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { RentalsService } from './rentals.service';
import { CreateRentalVehicleDto, SearchRentalVehiclesDto, UpdateRentalVehicleDto } from './dto/rental-vehicle.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard, Roles } from '../../common/guards/roles.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { RentalVehicleStatus } from './entities/rental-vehicle.entity';

@Controller('rentals')
export class RentalsController {
  constructor(private rentalsService: RentalsService) {}

  @Get()
  search(@Query() query: SearchRentalVehiclesDto) {
    return this.rentalsService.search(query);
  }

  @Get('mine')
  @UseGuards(JwtAuthGuard)
  myVehicles(@CurrentUser() user: { userId: string }) {
    return this.rentalsService.myVehicles(user.userId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.rentalsService.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  create(@CurrentUser() user: { userId: string }, @Body() dto: CreateRentalVehicleDto) {
    return this.rentalsService.create(user.userId, dto);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  update(
    @Param('id') id: string,
    @CurrentUser() user: { userId: string },
    @Body() dto: UpdateRentalVehicleDto,
  ) {
    return this.rentalsService.update(id, user.userId, dto);
  }

  @Patch(':id/approve')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  approve(@Param('id') id: string) {
    return this.rentalsService.setStatus(id, RentalVehicleStatus.APPROVED);
  }

  @Patch(':id/reject')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  reject(@Param('id') id: string) {
    return this.rentalsService.setStatus(id, RentalVehicleStatus.REJECTED);
  }
}
