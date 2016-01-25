# -*- encoding : utf-8 -*-
require "nokogiri"
require 'cgi'
require File.join(File.dirname(__FILE__), "lib/string_util")
require File.join(File.dirname(__FILE__), "lib/failure_renderer")
require File.join(File.dirname(__FILE__), "lib/context_renderer")
require File.join(File.dirname(__FILE__), "lib/rspec_test_result")

class RSpecOutputHandler
  attr_reader :test_result

  def initialize(test_result)
    @test_result = test_result
    @counts = {
      passed: 0,
      failed: 0,
      not_implemented: 0
    }
  end

  def render
    render_header
    render_examples
  end

  private

  def render_header
    render_red_green_header
    puts test_result.duration_str
    puts " "
  end

  def render_red_green_header
    total_count = test_result.examples_count
    fail_count = test_result.failure_count
    pending_count = test_result.pending_count

    if fail_count > 0
      puts "------------------------------"
      puts " FAIL: #{fail_count} PASS: #{total_count - (fail_count + pending_count)} PENDING: #{pending_count}"
      puts "------------------------------"
    else
      puts "++++++++++++++++++++++++++++++"
      puts "+ PASS: All #{total_count} Specs Pass!"
      puts "++++++++++++++++++++++++++++++"
    end

  end

  def render_examples
    (@doc/"div[@class~='example_group']").each do |context|
      RSpecContextRenderer.new(context, @counts)
    end
  end

end

test_result = RspecTestResult.new(STDIN.read)

RSpecOutputHandler.new(test_result).render
