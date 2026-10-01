# frozen_string_literal: true

require "json"
require "optparse"

module JWCalendar
  module CLI
    # Standard-library command-line interface used by the jwcalendar executable.
    class Runner
      def initialize(stdout: $stdout, stderr: $stderr)
        @stdout, @stderr = stdout, stderr
      end

      def run(argv)
        args = argv.dup
        command = args.shift
        return help if command.nil? || %w[-h --help help].include?(command)
        return version if %w[-v --version version].include?(command)

        case command
        when "inspect" then inspect_date(args)
        when "iso-week" then iso_week(args)
        when "jdn" then jdn(args)
        when "convert" then convert(args)
        when "grid" then grid(args)
        when "boundary" then boundary(args)
        else
          raise ArgumentError, "unknown command #{command.inspect}; run jwcalendar --help"
        end
      rescue OptionParser::ParseError, ArgumentError, Error => e
        @stderr.puts("jwcalendar: #{e.message}")
        2
      end

      private

      def inspect_date(args)
        options = { json: false, calendar: :gregorian }
        parser = OptionParser.new do |opts|
          opts.on("--json") { options[:json] = true }
          opts.on("--calendar NAME", %w[gregorian julian]) { |value| options[:calendar] = value.to_sym }
        end
        parser.parse!(args)
        date = parse_single_date(args, options[:calendar])
        iso = date.iso_week
        output = {
          date: date.to_s, calendar: date.calendar, weekday: date.weekday_name,
          weekday_number: date.weekday, ordinal_day: date.ordinal_day,
          jdn: date.to_jdn, iso_week_year: iso.week_year,
          iso_week: iso.week, iso_weekday: iso.weekday
        }
        if options[:json]
          @stdout.puts(JSON.pretty_generate(output))
        else
          output.each { |key, value| @stdout.puts("#{key.to_s.tr('_', ' ')}: #{value}") }
        end
        0
      end

      def iso_week(args)
        json, calendar = false, :gregorian
        parser = OptionParser.new do |opts|
          opts.on("--json") { json = true }
          opts.on("--calendar NAME", %w[gregorian julian]) { |value| calendar = value.to_sym }
        end
        parser.parse!(args)
        date = parse_single_date(args, calendar)
        week = date.iso_week
        output = { date: date.to_s, week_year: week.week_year, week: week.week,
                   weekday: week.weekday, weekday_name: week.weekday_name,
                   iso_date: week.to_s }
        @stdout.puts(json ? JSON.pretty_generate(output) : "#{week.to_s} (#{week.weekday_name})")
        0
      end

      def jdn(args)
        json, calendar = false, :gregorian
        parser = OptionParser.new do |opts|
          opts.on("--json") { json = true }
          opts.on("--calendar NAME", %w[gregorian julian]) { |value| calendar = value.to_sym }
        end
        parser.parse!(args)
        date = parse_single_date(args, calendar)
        result = { date: date.to_s, calendar: calendar, jdn: date.to_jdn,
                   jd_at_midnight: Conversion::JulianDayNumber.jd(date).to_s,
                   mjd_at_midnight: Conversion::JulianDayNumber.mjd(date).to_s }
        @stdout.puts(json ? JSON.pretty_generate(result) : result.map { |key, value| "#{key}: #{value}" }.join("\n"))
        0
      end

      def convert(args)
        options = { from: :gregorian, to: :julian, json: false }
        parser = OptionParser.new do |opts|
          opts.on("--from NAME", %w[gregorian julian]) { |value| options[:from] = value.to_sym }
          opts.on("--to NAME", %w[gregorian julian]) { |value| options[:to] = value.to_sym }
          opts.on("--json") { options[:json] = true }
        end
        parser.parse!(args)
        date = parse_single_date(args, options[:from])
        converted = Conversion::CalendarConverter.convert(date, to: options[:to])
        result = { input: date.to_s, from: options[:from], result: converted.to_s, to: options[:to], jdn: date.to_jdn }
        @stdout.puts(options[:json] ? JSON.pretty_generate(result) : "#{date} (#{options[:from]}) = #{converted} (#{options[:to]})")
        0
      end

      def grid(args)
        options = { week_start: :monday, fixed_weeks: nil, json: false, adjacent: true }
        parser = OptionParser.new do |opts|
          opts.on("--week-start DAY", %w[monday sunday]) { |value| options[:week_start] = value.to_sym }
          opts.on("--fixed-weeks N", Integer) { |value| options[:fixed_weeks] = value }
          opts.on("--no-adjacent") { options[:adjacent] = false }
          opts.on("--json") { options[:json] = true }
        end
        parser.parse!(args)
        raise ArgumentError, "expected one YYYY-MM month" unless args.length == 1 && (match = /\A(\d{4,})-(\d{2})\z/.match(args.first))

        layout = Grid::MonthGrid.new(year: match[1].to_i, month: match[2].to_i,
                                     week_start: options[:week_start], fixed_weeks: options[:fixed_weeks],
                                     include_adjacent: options[:adjacent])
        @stdout.puts(options[:json] ? JSON.pretty_generate(layout.to_h) : render_grid(layout))
        0
      end

      def boundary(args)
        json = false
        parser = OptionParser.new { |opts| opts.on("--json") { json = true } }
        parser.parse!(args)
        raise ArgumentError, "expected one year" unless args.length == 1 && /\A\d+\z/.match?(args.first)

        report = Boundary::Analyzer.year(args.first.to_i)
        @stdout.puts(json ? JSON.pretty_generate(report.to_h) : report.map { |event| "#{event[:date]} #{event[:type]}" }.join("\n"))
        0
      end

      def render_grid(layout)
        title = format("%04d-%02d", layout.year, layout.month)
        lines = ["#{title}  (week starts #{ISO::WeekDate::WEEKDAY_NAMES[layout.week_start - 1]})",
                 layout.day_names.map { |name| name[0, 3].rjust(4) }.join]
        layout.rows.each do |row|
          lines << row.map do |cell|
            if cell.date.nil?
              "    "
            elsif cell.in_current_month?
              cell.date.day.to_s.rjust(4)
            else
              "(#{cell.date.day})".rjust(4)
            end
          end.join
        end
        lines.join("\n")
      end

      def parse_single_date(args, calendar)
        raise ArgumentError, "expected one YYYY-MM-DD date" unless args.length == 1

        CivilDate.parse(args.first, calendar: calendar)
      end

      def version
        @stdout.puts("jwcalendar #{VERSION}")
        0
      end

      def help
        @stdout.puts <<~TEXT
          JW Calendar #{VERSION} — deterministic civil-date computation

          Usage: jwcalendar COMMAND [OPTIONS]

          Commands:
            inspect DATE           Show date, weekday, ordinal day and ISO week
            iso-week DATE          Show the ISO week date
            jdn DATE               Show JDN, exact JD and MJD at midnight
            convert DATE           Convert between Gregorian and Julian labels
            grid YYYY-MM           Print a structured month grid
            boundary YEAR          List calendar boundary cases

          Common options:
            --json                 Emit machine-readable JSON where supported
            --calendar NAME        Select gregorian or julian for date commands
            --help, --version      Show help or version
        TEXT
        0
      end
    end
  end
end
