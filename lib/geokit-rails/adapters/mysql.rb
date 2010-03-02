module Geokit
  module Adapters
    class MySQL < Abstract
      class SafeGeoString < String
        
      end
      
      def sphere_distance_sql(lat, lng, multiplier)
        %|
          (ACOS(least(1,COS(#{lat})*COS(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*COS(RADIANS(#{qualified_lng_column_name}))+
          COS(#{lat})*SIN(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*SIN(RADIANS(#{qualified_lng_column_name}))+
          SIN(#{lat})*SIN(RADIANS(#{qualified_lat_column_name}))))*#{multiplier})
         |
      end
      
      def flat_distance_sql(origin, lat_degree_units, lng_degree_units)
        %|
          SQRT(POW(#{lat_degree_units}*(#{origin.lat}-#{qualified_lat_column_name}),2)+
          POW(#{lng_degree_units}*(#{origin.lng}-#{qualified_lng_column_name}),2))
         |
      end
      
      def supports_spatial_column?
        true
      end
      
      require 'active_record/connection_adapters/mysql_adapter'

      ActiveRecord::ConnectionAdapters::MysqlAdapter.class_eval do
        def quote_with_geometry(value, column = nil)
          if value.kind_of?(SafeGeoString)
            value
          else
            quote_without_geometry(value,column)
          end
        end
        alias_method_chain :quote, :geometry
      end
      
      def spatial_column_data(lat, lng)
        SafeGeoString.new(%{GeomFromText('POINT(#{lat} #{lng})')})
      end
    end
  end
end