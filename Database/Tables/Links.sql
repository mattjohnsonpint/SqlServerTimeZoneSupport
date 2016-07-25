CREATE TABLE [Tzdb].[Links]
(
    [LinkZoneId] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY, 
    [CanonicalZoneId] UNIQUEIDENTIFIER NOT NULL, 
    CONSTRAINT [FK_Links_Zones_1] FOREIGN KEY ([LinkZoneId]) REFERENCES [Tzdb].[Zones]([Id]), 
    CONSTRAINT [FK_Links_Zones_2] FOREIGN KEY ([CanonicalZoneId]) REFERENCES [Tzdb].[Zones]([Id]) 
)
