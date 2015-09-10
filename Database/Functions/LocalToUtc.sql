CREATE FUNCTION [Tzdb].[LocalToUtc]
(
    @local datetime2,
    @tz varchar(50),
    @SkipOnSpringForwardGap bit = 1, -- if the local time is in a gap, 1 skips forward and 0 will return null
    @FirstOnFallBackOverlap bit = 1  -- if the local time is ambiguous, 1 uses the first (daylight) instance and 0 will use the second (standard) instance
)
RETURNS datetimeoffset
AS
BEGIN
    DECLARE @OffsetMinutes int

    DECLARE @ZoneId int
    SET @ZoneId = [Tzdb].GetZoneId(@tz)

    IF @FirstOnFallBackOverlap = 1
        SELECT TOP 1 @OffsetMinutes = [OffsetMinutes]
        FROM [Tzdb].[Intervals]
        WHERE [ZoneId] = @ZoneId
          AND [LocalStart] <= @local AND [LocalEnd] > @local
        ORDER BY [UtcStart]
    ELSE
        SELECT TOP 1 @OffsetMinutes = [OffsetMinutes]
        FROM [Tzdb].[Intervals]
        WHERE [ZoneId] = @ZoneId
          AND [LocalStart] <= @local AND [LocalEnd] > @local
        ORDER BY [UtcStart] DESC

    IF @OffsetMinutes IS NULL
    BEGIN
        IF @SkipOnSpringForwardGap = 0 RETURN NULL

        SET @local = DATEADD(MINUTE, CASE @tz WHEN 'Australia/Lord_Howe' THEN 30 ELSE 60 END, @local)
        SELECT TOP 1 @OffsetMinutes = [OffsetMinutes]
        FROM [Tzdb].[Intervals]
        WHERE [ZoneId] = @ZoneId
          AND [LocalStart] <= @local AND [LocalEnd] > @local
    END

    RETURN TODATETIMEOFFSET(DATEADD(MINUTE, -@OffsetMinutes, @local), 0)
END
