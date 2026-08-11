import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';

import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { ListingsModule } from './modules/listings/listings.module';
import { RentalsModule } from './modules/rentals/rentals.module';
import { BookingsModule } from './modules/bookings/bookings.module';
import { ReviewsModule } from './modules/reviews/reviews.module';
import { WalletModule } from './modules/wallet/wallet.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { NotificationsModule } from './modules/notifications/notifications.module';

import { User } from './modules/users/entities/user.entity';
import { CarListing } from './modules/listings/entities/listing.entity';
import { RentalVehicle } from './modules/rentals/entities/rental-vehicle.entity';
import { Booking } from './modules/bookings/entities/booking.entity';
import { Review } from './modules/reviews/entities/review.entity';
import { WalletLedgerEntry } from './modules/wallet/entities/wallet-ledger-entry.entity';
import { PaymentOrder } from './modules/payments/entities/payment-order.entity';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get<string>('DB_HOST', 'localhost'),
        port: config.get<number>('DB_PORT', 5432),
        username: config.get<string>('DB_USERNAME', 'postgres'),
        password: config.get<string>('DB_PASSWORD', 'postgres'),
        database: config.get<string>('DB_NAME', 'car_app'),
        entities: [
          User,
          CarListing,
          RentalVehicle,
          Booking,
          Review,
          WalletLedgerEntry,
          PaymentOrder,
        ],
        synchronize: config.get<string>('NODE_ENV') !== 'production', // dev only
        autoLoadEntities: true,
      }),
    }),
    AuthModule,
    UsersModule,
    ListingsModule,
    RentalsModule,
    BookingsModule,
    ReviewsModule,
    WalletModule,
    PaymentsModule,
    NotificationsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
