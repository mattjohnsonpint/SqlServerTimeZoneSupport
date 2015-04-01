using System.Diagnostics;
using System.Runtime.CompilerServices;

namespace System.Threading.Tasks
{
    internal class CachedAsyncLazy<T>
    {
        private readonly TimeSpan _cacheTimeout;
        private readonly Func<Task<T>> _taskFactory;
        private readonly Func<T> _valueFactory;
        private readonly Stopwatch _stopwatch = new Stopwatch();

        private AsyncLazy<T> _lazy;

        public CachedAsyncLazy(TimeSpan cacheTimeout, Func<T> valueFactory)
        {
            if (cacheTimeout <= TimeSpan.Zero)
                throw new ArgumentOutOfRangeException("cacheTimeout");

            _cacheTimeout = cacheTimeout;
            _valueFactory = valueFactory;
            _lazy = new AsyncLazy<T>(valueFactory);
        }

        public CachedAsyncLazy(TimeSpan cacheTimeout, Func<Task<T>> taskFactory)
        {
            if (cacheTimeout <= TimeSpan.Zero)
                throw new ArgumentOutOfRangeException("cacheTimeout");

            _cacheTimeout = cacheTimeout;
            _taskFactory = taskFactory;
            _lazy = new AsyncLazy<T>(taskFactory);
        }

        public Task<T> Value
        {
            get
            {
                if (IsValueCreated && _stopwatch.Elapsed >= _cacheTimeout)
                {
                    if (_valueFactory != null)
                        _lazy = new AsyncLazy<T>(_valueFactory);
                    else if (_taskFactory != null)
                        _lazy = new AsyncLazy<T>(_taskFactory);
                }

                var value = _lazy.Value;
                _stopwatch.Restart();
                return value;
            }
        }

        public bool IsValueCreated
        {
            get { return _lazy.IsValueCreated; }
        }

        public TaskAwaiter<T> GetAwaiter()
        {
            return _lazy.GetAwaiter();
        }

        public TimeSpan CacheTime
        {
            get { return _stopwatch.Elapsed; }
        }
    }
}