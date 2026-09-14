import 'package:drift/drift.dart';

enum SessionStatus { berjalan, selesai, adaItemHilang }

class LaundrySessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get sessionDate => dateTime().withDefault(currentDateAndTime)();
  TextColumn get status => textEnum<SessionStatus>()
      .withDefault(Constant(SessionStatus.berjalan.name))();
  DateTimeColumn get verifiedAt => dateTime().nullable()();
}