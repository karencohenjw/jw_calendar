# frozen_string_literal: true

require_relative "test_helper"
require "stringio"
require "json"
require "open3"
require "rbconfig"

class CLITest < Minitest::Test
  def run_cli(*args)
    out = StringIO.new
    err = StringIO.new
    status = JWCalendar::CLI::Runner.new(stdout: out, stderr: err).run(args)
    [status, out.string, err.string]
  end

  def test_version_help_and_inspection
    status, output, = run_cli("--version")
    assert_equal 0, status
    assert_equal "jwcalendar 0.1.1\n", output
    status, output, = run_cli("inspect", "2027-01-01")
    assert_equal 0, status
    assert_includes output, "iso week year: 2026"
    assert_includes output, "iso week: 53"
  end

  def test_json_commands_are_machine_readable
    status, output, = run_cli("inspect", "2027-01-01", "--json")
    assert_equal 0, status
    parsed = JSON.parse(output)
    assert_equal "Friday", parsed.fetch("weekday")
    assert_equal 2026, parsed.fetch("iso_week_year")
    assert_equal 53, parsed.fetch("iso_week")
    status, output, = run_cli("grid", "2027-01", "--fixed-weeks", "6", "--json")
    assert_equal 0, status
    assert_equal 6, JSON.parse(output).fetch("rows").length
    _, output, = run_cli("iso-week", "2027-01-01", "--json")
    assert_equal "2026-W53-5", JSON.parse(output).fetch("iso_date")
  end

  def test_cli_conversions_grid_and_error_codes
    status, output, = run_cli("convert", "1582-10-15", "--from", "gregorian", "--to", "julian")
    assert_equal 0, status
    assert_includes output, "1582-10-05"
    status, output, = run_cli("grid", "2027-01", "--week-start", "monday")
    assert_equal 0, status
    assert_includes output, "2027-01"
    status, = run_cli("inspect", "2027-02-29")
    assert_equal 2, status
    status, = run_cli("nonsense")
    assert_equal 2, status
  end

  def test_packaged_entry_point_runs_as_a_process
    executable = File.expand_path("../exe/jwcalendar", __dir__)
    output, error, status = Open3.capture3(RbConfig.ruby, executable, "iso-week", "2027-01-01", "--json")
    assert status.success?, error
    assert_equal "2026-W53-5", JSON.parse(output).fetch("iso_date")
  end
end
