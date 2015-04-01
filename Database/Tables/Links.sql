CREATE TABLE [Tzdb].[Links]
(
    [LinkZoneId] INT NOT NULL PRIMARY KEY, 
    [CanonicalZoneId] INT NOT NULL, 
    CONSTRAINT [FK_Links_Zones_1] FOREIGN KEY ([LinkZoneId]) REFERENCES [Tzdb].[Zones]([Id]), 
    CONSTRAINT [FK_Links_Zones_2] FOREIGN KEY ([CanonicalZoneId]) REFERENCES [Tzdb].[Zones]([Id]) 
)
