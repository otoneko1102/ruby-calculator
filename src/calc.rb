# frozen_string_literal: true

require "glimmer-dsl-libui"

include Glimmer

class CalculatorModel
  attr_reader :display_text

  def display_text=(text)
    @display_text = text.to_s
    Glimmer::DataBinding::Observer.proc { @display_text }.call
  end

  def initialize
    self.display_text = ""
  end

  def press(label)
    case label
    when "C"
      self.display_text = ""
    when "="
      self.display_text =
        begin
          calculate(display_text)
        rescue ZeroDivisionError
          "Error: Zero Division"
        rescue StandardError
          "Error: Invalid Syntax"
        end
    else
      self.display_text = "" if display_text.start_with?("Error:")
      self.display_text += label
    end
  end

  private

  def calculate(expression)
    return "" if expression.nil? || expression.empty?

    tokens = expression.scan(%r{\d+\.?\d*|[-+*/]})
    raise "Invalid Expression" if tokens.empty?

    ops = [%w[* /], %w[+ -]]
    ops.each do |op_group|
      i = 0
      while i < tokens.length
        next i += 1 unless op_group.include?(tokens[i])

        operator = tokens[i]
        left = tokens[i - 1].to_f
        right = tokens[i + 1].to_f

        raise ZeroDivisionError if operator == "/" && right.zero?

        result = left.public_send(operator, right)
        tokens[i - 1, 3] = result.to_s
        i = 0
      end
    end

    final_result = tokens.first.to_f
    if final_result == final_result.to_i
      final_result.to_i.to_s
    else
      final_result.to_s
    end
  end
end

@model = CalculatorModel.new

window("Ruby Calculator", 300, 400) do
  margined true

  on_closing do
    Glimmer::LibUI.quit
  end

  vertical_box do
    entry do
      text <=> [@model, :display_text]
      read_only true
    end

    grid do
      padded true
      buttons = [%w[7 8 9 /], %w[4 5 6 *], %w[1 2 3 -], %w[0 C = +]]
      buttons.each_with_index do |row, y|
        row.each_with_index do |label, x|
          button(label) do
            left x
            top y
            halign :fill
            valign :fill
            hexpand true
            vexpand true

            on_clicked { @model.press(label) }
          end
        end
      end
    end
  end
end.show
