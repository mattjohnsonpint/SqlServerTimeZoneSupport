# SQL Server Time Zone Support

This project adds full support for time zones to Microsoft SQL Server.

This implementation uses the industry standard [IANA time zone database][1].  If you are used to Microsoft Windows time zones, such as used with .NET `TimeZoneInfo`, consider using IANA time zones by using the [Noda Time][2] library.

You can read more about the IANA time zone database on [Wikipedia][3], and on [StackOverflow][4].

[A list of supported time zones can be found here.][12]

**Note:** This is an un-official, personal project. It is not developed or supported by Microsoft.

#### News:

SQL Server 2016 includes built-in support for Windows time zones using a new `AT TIME ZONE` syntax.  If you only need support for Windows time zones (not IANA time zones), consider using this feature *instead of this project*.  Read [the news here](http://blogs.technet.com/b/dataplatforminsider/archive/2015/11/30/sql-server-2016-community-technology-preview-3-1-is-available.aspx), and [documentation here](https://msdn.microsoft.com/en-us/library/mt612795.aspx).

### Installation

1. Download the latest `sqltz.zip` file from [the releases page][5].
2. Extract the zip file to a directory.
3. Open the `tzdb.sql` file, and run it against your database.
   - It will create all objects in an independent schema called `[Tzdb]`.
   - Microsoft SQL Server 2008 R2 and higher are supported, including Azure SQL Database.
4. Run the `SqlTzLoader.exe` utility, passing the connection string with the `-c` parameter.  
   For example:

   ```bat
   SqlTzLoader.exe -c"Server=YourServerName;Database=YourDatabaseName;Trusted_Connection=True"
   ```
   
   or
   
   ```bat
   SqlTzLoader.exe -c"Server=YourServerName;Database=YourDatabaseName;User Id=foo;Password=bar"
   ```
   It will download the latest time zone data and populate the tables in the database.

### Staying Current

You can re-execute the `SqlTzLoader.exe` utility any time.  If new time zone data is available, it will download it and update the tables.  You can easily run this from SQL Agent, Windows Scheduler, or Azure Scheduler.  Please do not run it more than once daily.

Our data comes from the [Noda Time TZDB NZD files][6], which in turn is generated directly from IANA releases.  Therefore, you may notice a short delay between publishing of IANA TZDB and the updated NZD file being made available.

### Usage

There are several user-defined functions exposed for common time zone conversion operations.  If you need additional functions, please create an issue in [the issue tracker][7].

#### UtcToLocal

Converts a `datetime` or `datetime2` value from UTC to a specific time zone.  The output is a `datetimeoffset` value that has the correct local time and offset for the time zone requested.

```sql
-- SYNTAX
Tzdb.UtcToLocal([utc_datetime], [dest_timezone])

-- EXAMPLE
SELECT Tzdb.UtcToLocal('2015-07-01 00:00:00', 'America/Los_Angeles')
-- output: '2015-06-30 17:00:00 -07:00'
```

#### LocalToUtc

Converts a `datetime` or `datetime2` value from a specific time zone to UTC.  The output is a `datetimeoffset` value that has the correct UTC time and an offset of `+00:00`.

Be aware that local-to-utc conversion is potentially a lossy operation.  For more details, consult [the dst tag wiki on StackOverflow][8].

```sql
-- SYNTAX
Tzdb.LocalToUtc([source_datetime], [source_timezone], [SkipOnSpringForwardGap], [FirstOnFallBackOverlap])

-- EXAMPLE
SELECT Tzdb.LocalToUtc('2015-07-01 00:00:00', 'America/Los_Angeles', 1, 1)
-- output: '2015-07-01 07:00:00 +00:00'
```

- The `SkipOnSpringForwardGap` parameter has the following options:
  - `1` : If a local time is in a DST gap due to the "spring-forward" DST transition, it is assumed that the clock *should* have sprung forward but didn't.  It therefore advances the time by the DST bias (usually 1 hour) so it can return a valid UTC time.  This is the default option.
  - `0` : If a local time is in a DST gap due to the "spring-forward" DST transition, the function returns `NULL`.

- The `FirstOnFallBackOverlap` parameter has the following options:
  - `1` : If a local time is ambiguous due to the "fall-back" DST transition, the *first* occurrence is assumed.  This will always be the *daylight* time instance.  This is the default option.
  - `0` : If a local time is ambiguous due to the "fall-back" DST transition, the *second* occurrence is assumed.  This will always be the *standard* time instance.


#### ConvertZone

Converts a `datetime` or `datetime2` value from a specific time zone to another specific time zone.  The output is a `datetimeoffset` value that has the correct local time and offset for the destination time zone requested.

The DST option flags are the same as the `LocalToUtc` function, and apply to the *source* time zone only.

```sql
-- SYNTAX
Tzdb.ConvertZone([source_datetime], [source_timezone], [dest_timezone], [SkipOnSpringForwardGap], [FirstOnFallBackOverlap])

-- EXAMPLE
SELECT Tzdb.ConvertZone('2015-07-01 00:00:00', 'America/Los_Angeles', 'Australia/Sydney', 1, 1)
-- output: '2015-07-01 17:00:00 +10:00'
```

#### SwitchZone

Converts a `datetimeoffset` value to a specific time zone.  The output is a `datetimeoffset` value that has the correct local time and offset for the time zone requested.

This function is similar to SQL Server's `SWITCHOFFSET` function, however it accepts a time zone instead of an offset - so it can take daylight saving time into account.

```sql
-- SYNTAX
Tzdb.SwitchZone([source_datetimeoffset], [dest_timezone])

-- EXAMPLE
SELECT Tzdb.SwitchZone('2015-07-01 00:00:00 -04:00', 'Asia/Kolkata')
-- output: '2015-07-01 09:30:00 +05:30'
```

#### GetZoneAbbreviation

Determines the correct abbreviation to use for the `datetimeoffset` value and time zone provided.  The output is a `varchar(10)` containing the abbreviation requested.

If you don't have a `datetimeoffset`, you should first obtain one either by using the `LocalToUtc` or `UtcToLocal` conversion functions, or by crafting it manually with SQL Server's `TODATETIMEOFFSET` function.  Do not pass a `datetime` or `datetime2` in, or the *server's* local time zone will get applied during the conversion.

Note that the abbreviations for many time zones depend on the specific date and time that they apply to.

```sql
-- SYNTAX
Tzdb.GetZoneAbbreviation([datetimeoffset], [timezone])

-- EXAMPLE
SELECT Tzdb.GetZoneAbbreviation('2015-07-01 00:00:00 -04:00', 'America/New_York')
-- output: 'EDT'
```

### Shameless Plug

If you want to learn more about time zones, and all of the lovely bits of programming that go around them, please consider watching my Pluralsight course, [Date and Time Fundamentals][9].

I also have a blog at [CodeOfMatt.com][10], which covers several issues surrounding dates, times, and time zones.

Thanks!

### License

This project is made freely available under [the MIT license][11].  Attribution is requested.

This project uses the following external resources:

- [Noda Time][2] (Apache licensed)
- [IANA Time Zone Database][1] (public domain)

[1]: http://www.iana.org/time-zones
[2]: http://nodatime.org
[3]: http://en.wikipedia.org/wiki/Tz_database
[4]: http://stackoverflow.com/tags/timezone/info
[5]: https://github.com/mj1856/SqlServerTimeZoneSupport/releases
[6]: http://nodatime.org/tzdb/
[7]: https://github.com/mj1856/SqlServerTimeZoneSupport/issues
[8]: http://stackoverflow.com/tags/dst/info
[9]: http://www.pluralsight.com/courses/date-time-fundamentals
[10]: http://codeofmatt.com
[11]: https://github.com/mj1856/SqlServerTimeZoneSupport/blob/master/LICENSE
[12]: http://en.wikipedia.org/wiki/List_of_tz_database_time_zones
