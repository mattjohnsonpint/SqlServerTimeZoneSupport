using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Threading;
using NodaTime;

namespace SqlTzLoader
{
    class Program
    {
        private static Options _options = new Options();

        static void Main(string[] args)
        {
            if (CommandLine.Parser.Default.ParseArgumentsStrict(args, _options))
            {
                if (_options.Verbose) Console.WriteLine("ConnectionString: {0}", _options.ConnectionString);
                
                AsyncPump.Run(() => MainAsync(args));
            }          
        }

        static async Task MainAsync(string[] args)
        {
            var tzdb = await CurrentTzdbProvider.LoadAsync();

            var zones = await WriteZonesAsync(tzdb.Ids);

            await WriteLinksAsync(zones, tzdb.Aliases);

            await WriteIntervalsAsync(zones, tzdb);

            await WriteVersion(tzdb.VersionId.Split(' ')[1]);
        }

        private static async Task<IDictionary<string, int>> WriteZonesAsync(IEnumerable<string> zones)
        {
            var dictionary = new Dictionary<string, int>();

            var cs = _options.ConnectionString;
            using (var connection = new SqlConnection(cs))
            {
                var command = new SqlCommand("[Tzdb].[AddZone]", connection) { CommandType = CommandType.StoredProcedure };
                command.Parameters.Add("@Name", SqlDbType.VarChar, 50);

                await connection.OpenAsync();

                foreach (var zone in zones)
                {
                    command.Parameters[0].Value = zone;
                    var id = (int)await command.ExecuteScalarAsync();
                    dictionary.Add(zone, id);
                }

                connection.Close();
            }

            return dictionary;
        }

        private static async Task WriteLinksAsync(IDictionary<string, int> zones, ILookup<string, string> aliases)
        {
            var cs = _options.ConnectionString;
            using (var connection = new SqlConnection(cs))
            {
                var command = new SqlCommand("[Tzdb].[AddLink]", connection) { CommandType = CommandType.StoredProcedure };
                command.Parameters.Add("@LinkZoneId", SqlDbType.Int);
                command.Parameters.Add("@CanonicalZoneId", SqlDbType.Int);

                await connection.OpenAsync();

                foreach (var alias in aliases)
                {
                    var canonicalId = zones[alias.Key];
                    foreach (var link in alias)
                    {
                        command.Parameters[0].Value = zones[link];
                        command.Parameters[1].Value = canonicalId;
                        await command.ExecuteNonQueryAsync();
                    }
                }

                connection.Close();
            }
        }

        private static async Task WriteIntervalsAsync(IDictionary<string, int> zones, CurrentTzdbProvider tzdb)
        {
            var currentUtcYear = SystemClock.Instance.GetCurrentInstant().InUtc().Year;
            var maxYear = currentUtcYear + 5;
            var maxInstant = new LocalDate(maxYear + 1, 1, 1).AtMidnight().InUtc().ToInstant();

            var links = tzdb.Aliases.SelectMany(x => x).OrderBy(x => x).ToList();

            foreach (var id in tzdb.Ids)
            {
                // Skip noncanonical zones
                if (links.Contains(id))
                    continue;

                using (var dt = new DataTable())
                {
                    dt.Columns.Add("UtcStart", typeof(DateTime));
                    dt.Columns.Add("UtcEnd", typeof(DateTime));
                    dt.Columns.Add("LocalStart", typeof(DateTime));
                    dt.Columns.Add("LocalEnd", typeof(DateTime));
                    dt.Columns.Add("OffsetMinutes", typeof(short));
                    dt.Columns.Add("Abbreviation", typeof(string));

                    var intervals = tzdb[id].GetZoneIntervals(Instant.MinValue, maxInstant);
                    foreach (var interval in intervals)
                    {
                        
                        var utcStart = !interval.HasStart
                            ? DateTime.MinValue
                            : interval.Start.ToDateTimeUtc();

                        var utcEnd = !interval.HasEnd
                            ? DateTime.MaxValue
                            : interval.End.ToDateTimeUtc();

                        var localStart = utcStart == DateTime.MinValue
                            ? DateTime.MinValue
                            : interval.IsoLocalStart.ToDateTimeUnspecified();

                        var localEnd = utcEnd == DateTime.MaxValue
                            ? DateTime.MaxValue
                            : interval.IsoLocalEnd.ToDateTimeUnspecified();


                        var offsetMinutes = (short)interval.WallOffset.ToTimeSpan().TotalMinutes;

                        var abbreviation = interval.Name;

                        if (abbreviation.StartsWith("Etc/"))
                        {
                            abbreviation = abbreviation.Substring(4);
                            if (abbreviation.StartsWith("GMT+"))
                                abbreviation = "GMT-" + abbreviation.Substring(4);
                            else if (abbreviation.StartsWith("GMT-"))
                                abbreviation = "GMT+" + abbreviation.Substring(4);
                        }

                        dt.Rows.Add(utcStart, utcEnd, localStart, localEnd, offsetMinutes, abbreviation);
                    }
                    if (_options.Verbose) Console.WriteLine("Processing: {0}", id);

                    var cs = _options.ConnectionString;
                    using (var connection = new SqlConnection(cs))
                    {
                        var command = new SqlCommand("[Tzdb].[SetIntervals]", connection)
                        {
                            CommandType = CommandType.StoredProcedure
                        };
                        command.Parameters.AddWithValue("@ZoneId", zones[id]);
                        var tvp = command.Parameters.AddWithValue("@Intervals", dt);
                        tvp.SqlDbType = SqlDbType.Structured;
                        tvp.TypeName = "[Tzdb].[IntervalTable]";

                        await connection.OpenAsync();
                        await command.ExecuteNonQueryAsync();
                        connection.Close();
                    }
                }
            }
        }

        private static async Task WriteVersion(string version)
        {
            var cs = _options.ConnectionString;
            using (var connection = new SqlConnection(cs))
            {
                var command = new SqlCommand("[Tzdb].[SetVersion]", connection) { CommandType = CommandType.StoredProcedure };
                command.Parameters.AddWithValue("@Version", version);

                await connection.OpenAsync();
                await command.ExecuteNonQueryAsync();
                connection.Close();
            }
        }
    }
}
