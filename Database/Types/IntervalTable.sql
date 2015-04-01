CREATE TYPE [Tzdb].[IntervalTable] AS TABLE
(
    [UtcStart] DATETIME2(0) NOT NULL,
    [UtcEnd] DATETIME2(0) NOT NULL,
    [LocalStart] DATETIME2(0) NOT NULL,
    [LocalEnd] DATETIME2(0) NOT NULL, 
    [OffsetMinutes] SMALLINT NOT NULL, 
    [Abbreviation] VARCHAR(10) NOT NULL
)