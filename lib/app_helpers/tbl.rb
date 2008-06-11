module AppHelpers
  
  def tbl(type, name, unit=nil, *widths, &block)
    @tbl        = @tbl        || {}
    @tbl[:rows] = @tbl[:rows] || {}

    case type
    when :row
      width = eval widths.join('+')

      @tbl[:rows][name] = {
        :count  => 0,
        :name   => name,
        :unit   => unit,
        :width  => width,
        :widths => widths
      }

      block_to_partial 'app_helpers/tbl/row', {
        :name  => name.to_s,
        :style => "width:#{width}#{unit.to_s};"
      }, &block

    when :cell      
      row    = @tbl[:rows][name]
      count  = row[:count]
      unit   = row[:unit]
      width  = row[:widths][row[:count]]

      margin = row[:margin] = row[:margin] || row[:width]

      if count == 0
        row[:margin] = margin -= width
        style = "margin-right:#{margin.to_s}#{unit};clear:left;"
      else
        style = "margin-left:-#{margin.to_s}#{unit};"
        row[:margin] = margin -= width
      end

      block_to_partial 'app_helpers/tbl/cell', {
        :name  => name.to_s,
        :count => row[:count].to_s,
        :style => "width:#{width.to_s}#{unit};" + style
      }, &block

      row[:count] += 1
      if row[:count] == row[:widths].length
        row[:count]  = 0
        row[:margin] = nil
      end
    end
  end
  
end