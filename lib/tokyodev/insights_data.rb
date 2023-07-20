require 'ostruct'
require 'yaml'

module Tokyodev
  module InsightsData
    class InsightsOpenStruct < OpenStruct
      def keys
        to_h.keys
      end

      def key?(key)
        to_h.key?(key)
      end

      def merge(other)
        self.class.new(to_h.merge(other.to_h))
      end

      def self.wrap(object)
        case object
        when Array
          object.map {|member| wrap(member)}
        when Hash
          new.tap do |wrapper|
            object.each_pair do |k,v|
              wrapper[k] = wrap(v)
            end
          end
        else
          object
        end
      end
    end

    def self.read_file(file)
      content = File.read(file)
      match = content.match(/^---(?<frontmatter>.*)---(?<additional_content>.*)$/m)
      if match
        frontmatter = YAML.safe_load(match[:frontmatter], permitted_classes: [], aliases: true)

        InsightsOpenStruct.wrap(frontmatter).tap do |data|
          data.postscript = match[:additional_content]
        end
      else
        data = YAML.safe_load(content, permitted_classes: [], aliases: true)
        InsightsOpenStruct.wrap(data)
      end
    end

    def self.key_name(file)
      File.basename(file).to_s.sub(/\.ya?ml$/, '')
    end

    def self.data
      InsightsOpenStruct.new.tap do |root|
        data_directory = Dir.glob(File.expand_path('../../../data/insights/*', __FILE__))
        data_directory.each do |path|
          root[key_name(path)] = InsightsOpenStruct.new.tap do |survey|
            survey.slides = InsightsOpenStruct.new.tap do |slides|
              slides_directory = File.join(path, "slides/*")
              Dir.glob(slides_directory).each do |file|
                key = key_name(file)
                slides[key] = read_file(file)
                slides[key].charts ||= InsightsOpenStruct.wrap([
                  id: key,
                  type: "ComboChart",
                ])
              end
            end
            survey.charts = InsightsOpenStruct.new.tap do |charts|
              charts_directory = File.join(path, "charts/*")
              Dir.glob(charts_directory).each do |file|
                charts[key_name(file)] = read_file(file)
              end
            end
            file = File.join(path, "slide_ordering.yml")
            survey.slide_ordering = read_file(file).map(&:to_sym)
          end
        end
      end
    end
  end
end
