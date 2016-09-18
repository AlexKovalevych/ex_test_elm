defmodule Gt.Manager.Date do
    use Timex

    @date_format "%Y-%m-%d"
    @month_format "%Y-%m"
    @time_format "%H-%M-%S"
    @stat_day_format "%y_%m_%d"
    @stat_month_format "%y_%m"

    def today do
        Timex.Date.today
    end

    def now do
        Timex.DateTime.now
    end

    def yesterday do
        today |> Timex.shift(days: -1)
    end

    def format(date, _) when is_bitstring(date) do
        date
    end
    def format(date, :date) do
        Timex.format!(date, @date_format, :strftime)
    end
    def format(date, :time) do
        Timex.format!(date, @time_format, :strftime)
    end
    def format(date, :month) do
        Timex.format!(date, @month_format, :strftime)
    end
    def format(date, :stat_date) do
        Timex.format!(date, @stat_day_format, :strftime)
    end
    def format(date, :stat_month) do
        Timex.format!(date, @stat_month_format, :strftime)
    end
    def format(date, :date, :tuple) do
        {date.year, date.month, date.day}
    end
    def format(date, :time, :tuple) do
        {date.hour, date.minute, date.second}
    end
    def format(date, :microtime, :tuple) do
        Tuple.append(format(date, :time, :tuple), date.millisecond)
    end

    def parse(date, :date) do
        Timex.parse!(date, @date_format, :strftime)
    end
    def parse(date, :stat_day) do
        Timex.parse!(date, @stat_day_format, :strftime)
    end

    def diff(start_date, end_date, :months) do
        Timex.diff(start_date, end_date, :months)
    end
    def diff(start_date, end_date, :days) do
        Timex.diff(start_date, end_date, :days)
    end

    def convert(date, :stat_day, :date) do
        [year, month, day] = String.split(date, "_")
        "20#{year}-#{month}-#{day}"
    end
    def convert(date, :date, :stat_day) do
        [year, month, day] = String.split(date, "-")
        year = String.slice(year, 2..3)
        "#{year}_#{month}_#{day}"
    end
    def convert(date, :date, :stat_month) do
        [year, month, _] = String.split(date, "-")
        year = String.slice(year, 2..3)
        "#{year}_#{month}"
    end

    def timestamp(date) do
        {mega, seconds, _} = case Date.to_timestamp(date) do
            {_, _, _} -> Date.to_timestamp(date)
            {:error, _} -> DateTime.to_timestamp(date)
        end
        (mega * 1000000 + seconds) * 1000
    end

    def to_bson(date, :date) when is_bitstring(date) do
        parsed_date = parse(date, :date)
        BSON.DateTime.from_datetime({
            format(parsed_date, :date, :tuple),
            format(parsed_date, :microtime, :tuple)
        })
    end
end
