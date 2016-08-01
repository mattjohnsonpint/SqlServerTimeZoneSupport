CREATE TABLE [Tzdb].[VersionInfo]
(
    [Version] CHAR(5) NOT NULL, 
    [Loaded] DATETIMEOFFSET(0) NOT NULL,
    CONSTRAINT [PK_VersionInfo] PRIMARY KEY ([Version])
)
