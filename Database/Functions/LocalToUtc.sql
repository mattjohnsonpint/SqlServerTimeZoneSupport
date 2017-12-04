﻿CREATE FUNCTION Tzdb.LocalToUtc
(
    @local datetime2,
    @tz varchar(50),
    @SkipOnSpringForwardGap bit = 1, -- if the local time is in a gap, 1 skips forward and 0 will return null
    @FirstOnFallBackOverlap bit = 1  -- if the local time is ambiguous, 1 uses the first (daylight) instance and 0 will use the second (standard) instance
)
RETURNS datetimeoffset
WITH SCHEMABINDING AS
BEGIN
    DECLARE @OffsetMinutes int

    IF @FirstOnFallBackOverlap = 1
        SELECT TOP 1 @OffsetMinutes = [OffsetMinutes]
        FROM [Tzdb].[Intervals] i INNER JOIN Tzdb.GetZoneId_Inline(@tz) z ON z.ZoneId = i.ZoneId
        WHERE [LocalStart] <= @local AND [LocalEnd] > @local
        ORDER BY [UtcStart]
    ELSE
        SELECT TOP 1 @OffsetMinutes = [OffsetMinutes]
        FROM [Tzdb].[Intervals] i INNER JOIN Tzdb.GetZoneId_Inline(@tz) z ON z.ZoneId = i.ZoneId
        WHERE [LocalStart] <= @local AND [LocalEnd] > @local
        ORDER BY [UtcStart] DESC

    IF @OffsetMinutes IS NULL
    BEGIN
        IF @SkipOnSpringForwardGap = 0 RETURN NULL

        SET @local = DATEADD(DAY, -1, @local) -- shift a day back to be guaranteed you move back into previous interval
        SELECT TOP 1 @OffsetMinutes = [OffsetMinutes] - 1440 -- subtracting number of minutes in a day from offset to account for previous shift
        FROM [Tzdb].[Intervals] i INNER JOIN Tzdb.GetZoneId_Inline(@tz) z ON z.ZoneId = i.ZoneId
        WHERE [LocalStart] <= @local AND [LocalEnd] > @local
    END

    RETURN TODATETIMEOFFSET(DATEADD(MINUTE, -@OffsetMinutes, @local), 0)
END
