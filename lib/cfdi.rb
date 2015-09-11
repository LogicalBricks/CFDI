# encoding: utf-8

require_relative 'version'
require_relative 'comun'
require_relative 'addenda'
require_relative 'impuestos'
require_relative 'nomina'
require_relative 'comprobante'
require_relative 'entidad'
require_relative 'concepto'
require_relative 'complemento'
require_relative 'xml'
require_relative 'certificado'
require_relative 'key'

# Comprobantes fiscales digitales por los internets
# 
# El sistema de generación y sellado de facturas es una patada en los
# genitales. Este gem pretende ser una bolsa de hielos. Igual va a doler, pero
# espero que al menos no quede moretón.
module CFDI

  require 'nokogiri'
  require 'time'
  require 'base64'
  
end
