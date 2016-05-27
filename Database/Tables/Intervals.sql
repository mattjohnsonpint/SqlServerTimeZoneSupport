CREATE TABLE [Tzdb].[Intervals]
(
    [Id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    [ZoneId] UNIQUEIDENTIFIER NOT NULL,
    [UtcStart] DATETIME2(0) NOT NULL,
    [UtcEnd] DATETIME2(0) NOT NULL,
    [LocalStart] DATETIME2(0) NOT NULL,
    [LocalEnd] DATETIME2(0) NOT NULL,
    [OffsetMinutes] SMALLINT NOT NULL,
    [Abbreviation] VARCHAR(10) NOT NULL,
    CONSTRAINT [FK_Intervals_Zones] FOREIGN KEY ([ZoneId]) REFERENCES [Tzdb].[Zones]([Id])
)

GO

CREATE NONCLUSTERED INDEX [IX_Intervals_Utc] ON [Tzdb].[Intervals]
(
    [ZoneId], [UtcStart], [UtcEnd]
)
INCLUDE
(
    [OffsetMinutes], [Abbreviation]
)

GO

CREATE NONCLUSTERED INDEX [IX_Intervals_Local] ON [Tzdb].[Intervals]
(
    [ZoneId], [LocalStart], [LocalEnd], [UtcStart]
)
INCLUDE
(
    [OffsetMinutes], [Abbreviation]
)
