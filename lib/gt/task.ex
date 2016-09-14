defmodule Gt.Task do
    require Logger
    use Timex
    import ExPrintf

    @type time :: {integer, integer, integer}

    defmacro __using__(_) do
        quote do
            use Mix.Task
            require Logger
            def run(args) do
                Logger.info title
                Gt.start_repo_supervisor
                Logger.configure([level: :info])
                start_time = Time.now
                OptionParser.parse(args)
                |> parse_args
                |> do_process
                Gt.Task.log_time_diff(start_time, Time.now)
            end
        end
    end

    @spec log_time_diff(time, time) :: String.t
    def log_time_diff(start_time, end_time) do
        minutes = Time.diff(end_time, start_time, :minutes)
        seconds = Time.diff(end_time, start_time, :seconds) - minutes * 60
        Logger.info sprintf("Completed in %sm %ss", [to_string(minutes), to_string(seconds)])
    end
end
