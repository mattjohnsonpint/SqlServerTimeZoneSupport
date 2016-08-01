CREATE TABLE [Tzdb].[Links]
(
    [LinkZoneId] INT NOT NULL, 
    [CanonicalZoneId] INT NOT NULL, 
    CONSTRAINT [PK_Links] PRIMARY KEY ([LinkZoneId]),
    CONSTRAINT [FK_Links_Zones_1] FOREIGN KEY ([LinkZoneId]) REFERENCES [Tzdb].[Zones]([Id]), 
    CONSTRAINT [FK_Links_Zones_2] FOREIGN KEY ([CanonicalZoneId]) REFERENCES [Tzdb].[Zones]([Id])
)
