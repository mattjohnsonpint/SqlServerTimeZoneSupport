CREATE PROCEDURE [Tzdb].[SetIntervals]
	@ZoneId int,
	@Intervals [Tzdb].[IntervalTable] READONLY
AS
DELETE FROM [Tzdb].[Intervals] WHERE [ZoneId] = @ZoneId
INSERT INTO [Tzdb].[Intervals] ([ZoneId], [UtcStart], [UtcEnd], [LocalStart], [LocalEnd], [OffsetMinutes], [Abbreviation])
SELECT @ZoneId as [ZoneId], [UtcStart], [UtcEnd], [LocalStart], [LocalEnd], [OffsetMinutes], [Abbreviation]
FROM @Intervals
