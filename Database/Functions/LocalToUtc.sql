CREATE FUNCTION Tzdb.LocalToUtc
(
    @local datetime2,
    @tz varchar(50),
    @SkipOnSpringForwardGap bit = 1, -- if the local time is in a gap, 1 skips forward and 0 will return null
    @FirstOnFallBackOverlap bit = 1  -- if the local time is ambiguous, 1 uses the first (daylight) instance and 0 will use the second (standard) instance
)
RETURNS datetimeoffset
WITH SCHEMABINDING AS
BEGIN
    DECLARE @OffsetMinutes int;

    IF @FirstOnFallBackOverlap = 1
        SELECT TOP 1 @OffsetMinutes = [OffsetMinutes]
        FROM [Tzdb].[Intervals] i INNER JOIN Tzdb.GetZoneId_Inline(@tz) z ON z.ZoneId = i.ZoneId
        WHERE i.[LocalStart] <= @local AND i.[LocalEnd] > @local
        ORDER BY i.[UtcStart] ASC;
    ELSE
        SELECT TOP 1 @OffsetMinutes = [OffsetMinutes]
        FROM [Tzdb].[Intervals] i INNER JOIN Tzdb.GetZoneId_Inline(@tz) z ON z.ZoneId = i.ZoneId
        WHERE i.[LocalStart] <= @local AND i.[LocalEnd] > @local
        ORDER BY i.[UtcStart] DESC;

    IF @OffsetMinutes IS NULL
    BEGIN
        IF @SkipOnSpringForwardGap = 0 RETURN NULL;

        SELECT TOP 1 @OffsetMinutes = i.[OffsetMinutes]
        FROM [Tzdb].[Intervals] i INNER JOIN Tzdb.GetZoneId_Inline(@tz) z ON z.ZoneId = i.ZoneId
        WHERE i.[LocalEnd] <= @local
        ORDER BY i.[UtcStart] DESC;
    END;

    RETURN TODATETIMEOFFSET(DATEADD(MINUTE, -@OffsetMinutes, @local), 0);
END;
