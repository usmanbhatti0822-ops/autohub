/**
 * Demo/portfolio data seeder. Wipes and repopulates the local database with
 * realistic-looking users, listings, rental vehicles, bookings and reviews
 * so the app is fully demonstrable without any real customers.
 *
 * Run with: npm run seed
 */
import 'dotenv/config';
import { DataSource } from 'typeorm';
import * as bcrypt from 'bcrypt';

import { User, UserRole, VerificationLevel } from './modules/users/entities/user.entity';
import {
  CarListing,
  ListingStatus,
  TransmissionType,
  FuelType,
  VehicleCategory,
} from './modules/listings/entities/listing.entity';
import { RentalVehicle, RentalVehicleStatus } from './modules/rentals/entities/rental-vehicle.entity';
import { Booking, BookingStatus } from './modules/bookings/entities/booking.entity';
import { Review, ReviewType } from './modules/reviews/entities/review.entity';
import { PaymentOrder } from './modules/payments/entities/payment-order.entity';
import { WalletLedgerEntry } from './modules/wallet/entities/wallet-ledger-entry.entity';

const dataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT) || 5432,
  username: process.env.DB_USERNAME || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'car_app',
  entities: [User, CarListing, RentalVehicle, Booking, Review, PaymentOrder, WalletLedgerEntry],
  synchronize: true,
});

function photos(seed: string, count = 3): string[] {
  return Array.from({ length: count }, (_, i) => `https://picsum.photos/seed/${seed}-${i}/1000/650`);
}

function avatar(seed: number): string {
  return `https://i.pravatar.cc/300?img=${seed}`;
}

function daysFromNow(days: number): Date {
  const d = new Date();
  d.setDate(d.getDate() + days);
  return d;
}

async function main() {
  await dataSource.initialize();
  console.log('Connected. Wiping existing demo data...');

  await dataSource.query(
    'TRUNCATE TABLE users, car_listings, rental_vehicles, bookings, reviews, payment_orders, wallet_ledger_entries RESTART IDENTITY CASCADE',
  );

  const users = dataSource.getRepository(User);
  const listings = dataSource.getRepository(CarListing);
  const vehicles = dataSource.getRepository(RentalVehicle);
  const bookings = dataSource.getRepository(Booking);
  const reviews = dataSource.getRepository(Review);

  // --- Demo account (works via BOTH phone/OTP and email/password) ---
  const demoUser = await users.save(
    users.create({
      fullName: 'Demo User',
      email: 'demo@autohub.pk',
      phone: '+923000000000',
      passwordHash: await bcrypt.hash('Demo1234', 10),
      phoneVerified: true,
      verificationLevel: VerificationLevel.PHONE_VERIFIED,
      role: UserRole.BUYER_SELLER,
      city: 'Karachi',
      avatarUrl: avatar(12),
    }),
  );

  // --- Sellers / rental owners ---
  const sellerData = [
    { fullName: 'Ahmed Khan', email: 'ahmed.khan@example.com', phone: '+923001112233', city: 'Karachi', img: 5 },
    { fullName: 'Sara Malik', email: 'sara.malik@example.com', phone: '+923004445566', city: 'Lahore', img: 25 },
    { fullName: 'Bilal Sheikh', email: 'bilal.sheikh@example.com', phone: '+923007778899', city: 'Islamabad', img: 33 },
    { fullName: 'Fatima Noor', email: 'fatima.noor@example.com', phone: '+923009990011', city: 'Lahore', img: 47 },
    { fullName: 'Usman Tariq', email: 'usman.tariq@example.com', phone: '+923002223344', city: 'Rawalpindi', img: 15 },
  ];
  const sellers = await users.save(
    sellerData.map((s) =>
      users.create({
        fullName: s.fullName,
        email: s.email,
        phone: s.phone,
        phoneVerified: true,
        verificationLevel: VerificationLevel.ID_VERIFIED,
        role: UserRole.CAR_OWNER,
        city: s.city,
        avatarUrl: avatar(s.img),
      }),
    ),
  );
  const [ahmed, sara, bilal, fatima, usman] = sellers;

  // Reviewer accounts, just so reviews have distinct authors.
  const reviewerData = [
    { fullName: 'Hassan Raza', email: 'hassan.raza@example.com', phone: '+923011112222', img: 8 },
    { fullName: 'Ayesha Siddiqui', email: 'ayesha.s@example.com', phone: '+923011113333', img: 29 },
    { fullName: 'Zainab Ali', email: 'zainab.ali@example.com', phone: '+923011114444', img: 44 },
  ];
  const reviewers = await users.save(
    reviewerData.map((r) =>
      users.create({
        fullName: r.fullName,
        email: r.email,
        phone: r.phone,
        phoneVerified: true,
        verificationLevel: VerificationLevel.PHONE_VERIFIED,
        role: UserRole.BUYER_SELLER,
        avatarUrl: avatar(r.img),
      }),
    ),
  );
  const [hassan, ayesha, zainab] = reviewers;

  // --- Car listings (for sale) across categories, cities, price points ---
  const listingSeed = [
    { make: 'Toyota', model: 'Corolla', year: 2022, variant: 'Altis 1.6', price: 6800000, city: 'Karachi', category: VehicleCategory.SEDAN, seller: ahmed, mileage: 18000, features: ['Cruise Control', 'Reverse Camera', 'Alloy Rims'], verified: true },
    { make: 'Honda', model: 'Civic', year: 2021, variant: 'Oriel', price: 7200000, city: 'Lahore', category: VehicleCategory.SEDAN, seller: sara, mileage: 25000, features: ['Sunroof', 'Push Start', 'Cruise Control'], verified: true },
    { make: 'Suzuki', model: 'Alto', year: 2023, variant: 'VXR', price: 2650000, city: 'Karachi', category: VehicleCategory.HATCHBACK, seller: ahmed, mileage: 8000, features: ['AC', 'Power Steering'], verified: false },
    { make: 'Suzuki', model: 'Cultus', year: 2022, variant: 'VXL', price: 3450000, city: 'Faisalabad', category: VehicleCategory.HATCHBACK, seller: usman, mileage: 15000, features: ['Alloy Rims', 'AC'], verified: true },
    { make: 'Toyota', model: 'Yaris', year: 2021, variant: 'ATIV X', price: 4650000, city: 'Islamabad', category: VehicleCategory.SEDAN, seller: bilal, mileage: 32000, features: ['Reverse Camera', 'Cruise Control'], verified: false },
    { make: 'Honda', model: 'City', year: 2023, variant: 'Aspire', price: 5900000, city: 'Lahore', category: VehicleCategory.SEDAN, seller: sara, mileage: 6000, features: ['Push Start', 'Sunroof'], verified: true },
    { make: 'Toyota', model: 'Fortuner', year: 2021, variant: 'Sigma 4', price: 15500000, city: 'Karachi', category: VehicleCategory.SUV, seller: ahmed, mileage: 28000, features: ['4WD', 'Leather Seats', 'Sunroof', '360 Camera'], verified: true },
    { make: 'Kia', model: 'Sportage', year: 2022, variant: 'AWD', price: 11200000, city: 'Islamabad', category: VehicleCategory.SUV, seller: bilal, mileage: 14000, features: ['Panoramic Sunroof', 'Ventilated Seats'], verified: true },
    { make: 'MG', model: 'HS', year: 2023, variant: 'Trophy', price: 10800000, city: 'Lahore', category: VehicleCategory.SUV, seller: fatima, mileage: 5000, features: ['360 Camera', 'ADAS', 'Panoramic Roof'], verified: true },
    { make: 'Honda', model: 'BR-V', year: 2022, variant: 'S', price: 6400000, city: 'Rawalpindi', category: VehicleCategory.SUV, seller: usman, mileage: 20000, features: ['7 Seater', 'Cruise Control'], verified: false },
    { make: 'Mercedes-Benz', model: 'C-Class', year: 2020, variant: 'C200', price: 22500000, city: 'Karachi', category: VehicleCategory.LUXURY, seller: ahmed, mileage: 35000, features: ['Leather Seats', 'Panoramic Roof', 'Ambient Lighting', 'Burmester Sound'], verified: true },
    { make: 'BMW', model: '3 Series', year: 2021, variant: '330i', price: 24800000, city: 'Lahore', category: VehicleCategory.LUXURY, seller: sara, mileage: 21000, features: ['M Sport Package', 'Head-Up Display'], verified: true },
    { make: 'Audi', model: 'A4', year: 2020, variant: '40 TFSI', price: 19800000, city: 'Islamabad', category: VehicleCategory.LUXURY, seller: bilal, mileage: 30000, features: ['Virtual Cockpit', 'Bang & Olufsen Sound'], verified: false },
    { make: 'Kia', model: 'Picanto', year: 2023, variant: 'AT', price: 3950000, city: 'Faisalabad', category: VehicleCategory.ECONOMY, seller: usman, mileage: 4000, features: ['AC', 'Infotainment Screen'], verified: true },
    { make: 'Changan', model: 'Alsvin', year: 2023, variant: 'Lumiere+', price: 4550000, city: 'Karachi', category: VehicleCategory.SEDAN, seller: ahmed, mileage: 9000, features: ['Reverse Camera', 'Touchscreen'], verified: false },
    { make: 'Hyundai', model: 'Tucson', year: 2022, variant: 'AWD', price: 12900000, city: 'Lahore', category: VehicleCategory.SUV, seller: fatima, mileage: 17000, features: ['Panoramic Sunroof', 'Wireless CarPlay'], verified: true },
  ];

  await listings.save(
    listingSeed.map((c, i) =>
      listings.create({
        sellerId: c.seller.id,
        make: c.make,
        model: c.model,
        year: c.year,
        variant: c.variant,
        mileageKm: c.mileage,
        price: c.price,
        city: c.city,
        transmission: TransmissionType.AUTOMATIC,
        fuelType: c.category === VehicleCategory.LUXURY ? FuelType.PETROL : (i % 5 === 0 ? FuelType.HYBRID : FuelType.PETROL),
        category: c.category,
        seats: c.category === VehicleCategory.SUV ? 7 : 5,
        doors: c.category === VehicleCategory.HATCHBACK ? 5 : 4,
        features: c.features,
        photoUrls: photos(`${c.make}-${c.model}-${c.year}`.toLowerCase().replace(/\s+/g, '')),
        description: `Well-maintained ${c.year} ${c.make} ${c.model} ${c.variant}, single owner, all documents clear. Located in ${c.city}.`,
        status: ListingStatus.APPROVED,
        isVerified: c.verified,
      }),
    ),
  );

  // --- Rental vehicles ---
  const rentalSeed = [
    { make: 'Toyota', model: 'Corolla', year: 2022, city: 'Karachi', pickup: 'Shahrah-e-Faisal, Karachi', rate: 8500, deposit: 20000, driver: true, owner: ahmed, category: VehicleCategory.SEDAN, features: ['Cruise Control', 'Bluetooth'] },
    { make: 'Honda', model: 'Civic', year: 2021, city: 'Lahore', pickup: 'Gulberg, Lahore', rate: 9500, deposit: 25000, driver: true, owner: sara, category: VehicleCategory.SEDAN, features: ['Sunroof', 'Bluetooth'] },
    { make: 'Suzuki', model: 'Swift', year: 2022, city: 'Islamabad', pickup: 'F-7 Markaz, Islamabad', rate: 5500, deposit: 12000, driver: false, owner: bilal, category: VehicleCategory.HATCHBACK, features: ['AC', 'Bluetooth'] },
    { make: 'Toyota', model: 'Fortuner', year: 2021, city: 'Karachi', pickup: 'DHA Phase 5, Karachi', rate: 22000, deposit: 60000, driver: true, owner: ahmed, category: VehicleCategory.SUV, features: ['4WD', 'Leather Seats'] },
    { make: 'Kia', model: 'Sportage', year: 2022, city: 'Lahore', pickup: 'DHA Phase 6, Lahore', rate: 16000, deposit: 40000, driver: false, owner: fatima, category: VehicleCategory.SUV, features: ['Panoramic Sunroof'] },
    { make: 'Mercedes-Benz', model: 'C-Class', year: 2020, city: 'Islamabad', pickup: 'Blue Area, Islamabad', rate: 35000, deposit: 100000, driver: true, owner: bilal, category: VehicleCategory.LUXURY, features: ['Leather Seats', 'Chauffeur Available'] },
    { make: 'Honda', model: 'BR-V', year: 2022, city: 'Rawalpindi', pickup: 'Bahria Town, Rawalpindi', rate: 12000, deposit: 25000, driver: false, owner: usman, category: VehicleCategory.SUV, features: ['7 Seater'] },
    { make: 'Suzuki', model: 'Cultus', year: 2022, city: 'Faisalabad', pickup: 'Susan Road, Faisalabad', rate: 5000, deposit: 10000, driver: false, owner: usman, category: VehicleCategory.ECONOMY, features: ['AC'] },
  ];

  const savedVehicles = await vehicles.save(
    rentalSeed.map((v) =>
      vehicles.create({
        ownerId: v.owner.id,
        make: v.make,
        model: v.model,
        year: v.year,
        transmission: TransmissionType.AUTOMATIC,
        fuelType: FuelType.PETROL,
        category: v.category,
        seats: v.category === VehicleCategory.SUV ? 7 : 5,
        doors: 4,
        features: v.features,
        city: v.city,
        pickupLocation: v.pickup,
        dailyRate: v.rate,
        securityDeposit: v.deposit,
        driverAvailable: v.driver,
        photoUrls: photos(`rent-${v.make}-${v.model}-${v.year}`.toLowerCase().replace(/\s+/g, '')),
        description: `${v.year} ${v.make} ${v.model}, clean interior, regularly serviced. Pickup from ${v.pickup}.`,
        status: RentalVehicleStatus.APPROVED,
      }),
    ),
  );

  // --- Demo user's bookings, spanning every status for a realistic My Bookings screen ---
  await bookings.save([
    bookings.create({
      vehicleId: savedVehicles[0].id,
      renterId: demoUser.id,
      startDate: daysFromNow(5),
      endDate: daysFromNow(8),
      totalPrice: 3 * Number(savedVehicles[0].dailyRate),
      securityDeposit: savedVehicles[0].securityDeposit,
      withDriver: true,
      status: BookingStatus.REQUESTED,
    }),
    bookings.create({
      vehicleId: savedVehicles[2].id,
      renterId: demoUser.id,
      startDate: daysFromNow(2),
      endDate: daysFromNow(4),
      totalPrice: 2 * Number(savedVehicles[2].dailyRate),
      securityDeposit: savedVehicles[2].securityDeposit,
      withDriver: false,
      status: BookingStatus.CONFIRMED,
    }),
    bookings.create({
      vehicleId: savedVehicles[4].id,
      renterId: demoUser.id,
      startDate: daysFromNow(-10),
      endDate: daysFromNow(-7),
      totalPrice: 3 * Number(savedVehicles[4].dailyRate),
      securityDeposit: savedVehicles[4].securityDeposit,
      withDriver: false,
      status: BookingStatus.COMPLETED,
    }),
    bookings.create({
      vehicleId: savedVehicles[6].id,
      renterId: demoUser.id,
      startDate: daysFromNow(-20),
      endDate: daysFromNow(-18),
      totalPrice: 2 * Number(savedVehicles[6].dailyRate),
      securityDeposit: savedVehicles[6].securityDeposit,
      withDriver: false,
      status: BookingStatus.CANCELLED,
      cancellationReason: 'Change of travel plans',
    }),
  ]);

  // --- Reviews for sellers/owners so seller ratings + car detail reviews have content ---
  await reviews.save([
    reviews.create({ authorId: hassan.id, subjectId: ahmed.id, type: ReviewType.RENTER_TO_OWNER, rating: 5, comment: 'Smooth rental experience, car was spotless and driver was on time.' }),
    reviews.create({ authorId: ayesha.id, subjectId: ahmed.id, type: ReviewType.BUYER_TO_SELLER, rating: 4, comment: 'Good condition car, price was fair. Minor delay in paperwork.' }),
    reviews.create({ authorId: zainab.id, subjectId: sara.id, type: ReviewType.BUYER_TO_SELLER, rating: 5, comment: 'Excellent seller, very responsive and honest about the car history.' }),
    reviews.create({ authorId: hassan.id, subjectId: sara.id, type: ReviewType.RENTER_TO_OWNER, rating: 5, comment: 'Civic was in great shape, would rent again.' }),
    reviews.create({ authorId: ayesha.id, subjectId: bilal.id, type: ReviewType.RENTER_TO_OWNER, rating: 4, comment: 'Good car but pickup location was a bit hard to find.' }),
    reviews.create({ authorId: zainab.id, subjectId: fatima.id, type: ReviewType.BUYER_TO_SELLER, rating: 5, comment: 'Very professional, highly recommend.' }),
    reviews.create({ authorId: demoUser.id, subjectId: usman.id, type: ReviewType.RENTER_TO_OWNER, rating: 5, comment: 'Great value for money, will book again on my next trip.', relatedBookingId: undefined }),
  ]);

  console.log('Seed complete:');
  console.log(`  Users: ${sellers.length + reviewers.length + 1}`);
  console.log(`  Car listings: ${listingSeed.length}`);
  console.log(`  Rental vehicles: ${rentalSeed.length}`);
  console.log('  Demo login (phone/OTP): +923000000000, OTP 1234');
  console.log('  Demo login (email/password): demo@autohub.pk / Demo1234');

  await dataSource.destroy();
}

main().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
