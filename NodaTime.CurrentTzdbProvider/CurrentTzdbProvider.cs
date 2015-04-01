using System;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using NodaTime.TimeZones;

namespace NodaTime
{
    public sealed class CurrentTzdbProvider : IDateTimeZoneProvider
    {
        private static readonly CachedAsyncLazy<CurrentTzdbProvider> Instance = 
            new CachedAsyncLazy<CurrentTzdbProvider>(TimeSpan.FromDays(1), () => DownloadAsync());

        private readonly IDateTimeZoneProvider _provider;
        private readonly ILookup<string, string> _aliases; 

        private CurrentTzdbProvider(IDateTimeZoneProvider provider, ILookup<string, string> aliases)
        {
            _provider = provider;
            _aliases = aliases;
        }

        public static async Task<CurrentTzdbProvider> LoadAsync()
        {
            return await Instance;
        }

        private static async Task<CurrentTzdbProvider> DownloadAsync()
        {
            using (var client = new HttpClient())
            {
                var latest = new Uri((await client.GetStringAsync("http://nodatime.org/tzdb/latest.txt")).TrimEnd());
                var fileName = latest.Segments.Last();
                var path = Path.Combine(Path.GetTempPath(), fileName);

                if (!File.Exists(path))
                {
                    using (var httpStream = await client.GetStreamAsync(latest))
                    using (var fileStream = File.Create(path))
                    {
                        await httpStream.CopyToAsync(fileStream);
                    }
                }

                using (var fileStream = File.OpenRead(path))
                {
                    var source = TzdbDateTimeZoneSource.FromStream(fileStream);
                    var provider = new DateTimeZoneCache(source);
                    return new CurrentTzdbProvider(provider, source.Aliases);
                }
            }
        }

        public ILookup<string, string> Aliases
        {
            get { return _aliases; }
        }

        public DateTimeZone GetSystemDefault()
        {
            return _provider.GetSystemDefault();
        }

        public DateTimeZone GetZoneOrNull(string id)
        {
            return _provider.GetZoneOrNull(id);
        }

        public string VersionId
        {
            get { return _provider.VersionId; }
        }

        public ReadOnlyCollection<string> Ids
        {
            get { return _provider.Ids; }
        }

        public DateTimeZone this[string id]
        {
            get { return _provider[id]; }
        }
    }
}
