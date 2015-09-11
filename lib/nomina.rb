module CFDI
  class Nomina < ElementoComprobante
    # @private
    @cadenaOriginal = [
      :RegistroPatronal, :NumEmpleado, :CURP, :TipoRegimen, :CLABE, :Banco,
      :NumSeguridadSocial, :FechaPago, :FechaInicialPago, :FechaFinalPago,
      :NumDiasPagados, :Departamento, :Puesto, :TipoJornada, :PeriodicidadPago,
      :Percepciones, :Deducciones, :HorasExtras, :Incapacidades
    ]
    # @private
    attr_accessor *@cadenaOriginal

    def initialize
      @Percepciones = Percepciones.new
      @Deducciones = Deducciones.new
      @HorasExtras = []
      @Incapacidades = []
    end

    def NumDiasPagados=(numero)
      @NumDiasPagados = numero.to_i
    end

    class Percepciones < ElementoComprobante
      # @private
      @cadenaOriginal = [:TotalGravado, :TotalExento, :percepciones]
      # @private
      attr_accessor *@cadenaOriginal

      def initialize
        @percepciones = []
      end

      def TotalGravado=(valor)
        @TotalGravado = valor.to_f
      end

      def TotalExento=(valor)
        @TotalExento = valor.to_f
      end
    end

    class Percepcion < ElementoComprobante
      # @private
      @cadenaOriginal = [:TipoPercepcion, :Clave, :Concepto, :ImporteGravado, :ImporteExento]
      # @private
      attr_accessor *@cadenaOriginal

      def ImporteGravado=(valor)
        @ImporteGravado = valor.to_f
      end

      def ImporteExento=(valor)
        @ImporteExento = valor.to_f
      end
    end

    class Deducciones < ElementoComprobante
      # @private
      @cadenaOriginal = [:TotalGravado, :TotalExento, :deducciones]
      # @private
      attr_accessor *@cadenaOriginal

      def initialize
        @deducciones = []
      end

      def TotalGravado=(valor)
        @TotalGravado = valor.to_f
      end

      def TotalExento=(valor)
        @TotalExento = valor.to_f
      end
    end

    class Deduccion < ElementoComprobante
      # @private
      @cadenaOriginal = [:TipoDeduccion, :Clave, :Concepto, :ImporteGravado, :ImporteExento]
      # @private
      attr_accessor *@cadenaOriginal

      def ImporteGravado=(valor)
        @ImporteGravado = valor.to_f
      end

      def ImporteExento=(valor)
        @ImporteExento = valor.to_f
      end
    end

    class HorasExtra < ElementoComprobante
      # @private
      @cadenaOriginal = [:Dias, :HorasExtra, :ImportePagado, :TipoHoras]
      # @private
      attr_accessor *@cadenaOriginal
    end

    class Incapacidad < ElementoComprobante
      # @private
      @cadenaOriginal = [:DiasIncapacidad, :TipoIncapacidad, :Descuento]
      # @private
      attr_accessor *@cadenaOriginal
    end

  end
end
