module CFDI


  # Crea un CFDI::Comprobante desde un string XML
  # @param  data [String, IO] El XML a parsear, según acepte Nokogiri
  #
  # @return [CFDI::Comprobante] El comprobante parseado
  def self.from_xml(data)
    xml = Nokogiri::XML(data);
    xml.remove_namespaces!

    comprobante = xml.at_xpath('//Comprobante')
    emisor = xml.at_xpath('//Emisor')
    de = emisor.at_xpath('//DomicilioFiscal')
    exp = emisor.at_xpath('//ExpedidoEn')
    receptor = xml.at_xpath('//Receptor')
    dr = receptor.at_xpath('//Domicilio')

    factura = xml.at_xpath('//Nomina') ? ComprobanteNomina.new : Comprobante.new

    factura.version = comprobante.attr('version')
    factura.serie = comprobante.attr('serie')
    factura.folio = comprobante.attr('folio')
    factura.fecha = Time.parse(comprobante.attr('fecha'))
    factura.noCertificado = comprobante.attr('noCertificado')
    factura.certificado = comprobante.attr('certificado')
    factura.sello = comprobante.attr('sello')
    factura.formaDePago = comprobante.attr('formaDePago')
    factura.condicionesDePago = comprobante.attr('condicionesDePago')
    factura.tipoDeComprobante = comprobante.attr('tipoDeComprobante')
    factura.lugarExpedicion = comprobante.attr('LugarExpedicion')
    factura.metodoDePago = comprobante.attr('metodoDePago')
    factura.moneda = comprobante.attr('Moneda')
    factura.NumCtaPago = comprobante.attr('NumCtaPago')
    factura.total = comprobante.attr('total').to_f
    factura.subTotal = comprobante.attr('subTotal').to_f


    rf = emisor.at_xpath('//RegimenFiscal')

    emisor = {
      rfc: emisor.attr('rfc'),
      nombre: emisor.attr('nombre'),
      regimenFiscal: rf  && rf.attr('Regimen'),
      domicilioFiscal: {
        calle: de.attr('calle'),
        noExterior: de.attr('noExterior'),
        noInterior: de.attr('noInterior'),
        colonia: de.attr('colonia'),
        localidad: de.attr('localidad'),
        referencia: de.attr('referencia'),
        municipio: de.attr('municipio'),
        estado: de.attr('estado'),
        pais: de.attr('pais'),
        codigoPostal: de.attr('codigoPostal')
      }
    }

    if exp
      emisor[:expedidoEn] = {
        calle: exp.attr('calle'),
        noExterior: exp.attr('noExterior'),
        no_int: exp.attr('noInterior'),
        colonia: exp.attr('colonia'),
        localidad: exp.attr('localidad'),
        referencia: exp.attr('referencia'),
        municipio: exp.attr('municipio'),
        estado: exp.attr('estado'),
        pais: exp.attr('pais'),
        codigoPostal: exp.attr('codigoPostal')
      }
    end

    factura.emisor = emisor;

    factura.receptor = {
      rfc: receptor.attr('rfc'),
      nombre: receptor.attr('nombre')
    }

    if dr
      factura.receptor.domicilioFiscal = {
        calle: dr.attr('calle'),
        noExterior: dr.attr('noExterior'),
        noInterior: dr.attr('noInterior'),
        colonia: dr.attr('colonia'),
        localidad: dr.attr('localidad'),
        referencia: dr.attr('referencia'),
        municipio: dr.attr('municipio'),
        estado: dr.attr('estado'),
        pais: dr.attr('pais'),
        codigoPostal: dr.attr('codigoPostal')
      }
    end

    factura.conceptos = []
    #puts "conceptos: #{factura.conceptos.length}"
    xml.xpath('//Concepto').each do |concepto|
      total = concepto.attr('importe').to_f
      hash = {
        cantidad: concepto.attr('cantidad').to_f,
        unidad: concepto.attr('unidad'),
        noIdentificacion: concepto.attr('noIdentificacion'),
        descripcion: concepto.attr('descripcion'),
        valorUnitario: concepto.attr('valorUnitario').to_f
      }
      #puts "hash: ", hash
      factura.conceptos << Concepto.new(hash)
    end

    timbre = xml.at_xpath('//TimbreFiscalDigital')
    if timbre
      version = timbre.attr('version');
      uuid = timbre.attr('UUID')
      fecha = timbre.attr('FechaTimbrado')
      sello = timbre.attr('selloCFD')
      certificado = timbre.attr('noCertificadoSAT')
      factura.complemento = {
        UUID: uuid,
        selloCFD: sello,
        FechaTimbrado: fecha,
        noCertificadoSAT: certificado,
        version: version,
        selloSAT: timbre.attr('selloSAT')
      }
    end

    impuestos_node = comprobante.at_xpath('//Impuestos')

    traslados_node = impuestos_node.xpath('//Traslados')
    unless traslados_node.empty?
      factura.impuestos.totalImpuestosTrasladados = impuestos_node.attr('totalImpuestosTrasladados')
      traslados = []
      traslados_node.xpath('//Traslado').each do |traslado_node|
        traslado = Traslado.new
        traslado.impuesto = traslado_node.attr('impuesto') if traslado_node.attr('impuesto')
        traslado.tasa = traslado_node.attr('tasa').to_f if traslado_node.attr('tasa')
        traslado.importe = traslado_node.attr('importe').to_f if traslado_node.attr('importe')
        traslados << traslado
      end
      factura.impuestos.traslados = traslados
    end

    retenciones_node = impuestos_node.xpath('//Retenciones')
    unless retenciones_node.empty?
      factura.impuestos.totalImpuestosRetenidos = impuestos_node.attr('totalImpuestosRetenidos')
      retenciones = []
      retenciones_node.xpath('//Retencion').each do |retencion_node|
        retencion = Retencion.new
        retencion.impuesto = retencion_node.attr('impuesto') if retencion_node.attr('impuesto')
        retencion.tasa = retencion_node.attr('tasa').to_f if retencion_node.attr('tasa')
        retencion.importe = retencion_node.attr('importe').to_f if retencion_node.attr('importe')
        retenciones << retencion
      end
      factura.impuestos.retenciones = retenciones
    end

    nomina_node = xml.at_xpath('//Nomina')
    if nomina_node
      nomina = Nomina.new
      nomina.RegistroPatronal = nomina_node.attr('RegistroPatronal')
      nomina.NumEmpleado = nomina_node.attr('NumEmpleado')
      nomina.CURP = nomina_node.attr('CURP')
      nomina.TipoRegimen = nomina_node.attr('TipoRegimen')
      nomina.NumSeguridadSocial = nomina_node.attr('NumSeguridadSocial')
      nomina.FechaPago = nomina_node.attr('FechaPago')
      nomina.FechaInicialPago = nomina_node.attr('FechaInicialPago')
      nomina.FechaFinalPago = nomina_node.attr('FechaFinalPago')
      nomina.NumDiasPagados = nomina_node.attr('NumDiasPagados')
      nomina.Departamento = nomina_node.attr('Departamento')
      nomina.CLABE = nomina_node.attr('CLABE')
      nomina.Banco = nomina_node.attr('Banco')
      nomina.Puesto = nomina_node.attr('Puesto')
      nomina.PeriodicidadPago = nomina_node.attr('PeriodicidadPago')

      deducciones_node = nomina_node.at_xpath('//Deducciones')
      if deducciones_node
        deducciones = Nomina::Deducciones.new
        deducciones.TotalGravado = deducciones_node.attr('TotalGravado')
        deducciones.TotalExento = deducciones_node.attr('TotalExento')
        deducciones_node.xpath('//Deduccion').each do |deduccion_node|
          deduccion = Nomina::Deduccion.new
          deduccion.TipoDeduccion = deduccion_node.attr('TipoDeduccion')
          deduccion.Clave = deduccion_node.attr('Clave')
          deduccion.Concepto = deduccion_node.attr('Concepto')
          deduccion.ImporteGravado = deduccion_node.attr('ImporteGravado')
          deduccion.ImporteExento = deduccion_node.attr('ImporteExento')
          deducciones.deducciones << deduccion
        end
        nomina.Deducciones = deducciones
      end

      percepciones_node = nomina_node.at_xpath('//Percepciones')
      if percepciones_node
        percepciones = Nomina::Percepciones.new
        percepciones.TotalGravado = percepciones_node.attr('TotalGravado')
        percepciones.TotalExento = percepciones_node.attr('TotalExento')
        percepciones_node.xpath('//Percepcion').each do |percepcion_node|
          percepcion = Nomina::Percepcion.new
          percepcion.TipoPercepcion = percepcion_node.attr('TipoPercepcion')
          percepcion.Clave = percepcion_node.attr('Clave')
          percepcion.Concepto = percepcion_node.attr('Concepto')
          percepcion.ImporteGravado = percepcion_node.attr('ImporteGravado')
          percepcion.ImporteExento = percepcion_node.attr('ImporteExento')
          percepciones.percepciones << percepcion
        end
        nomina.Percepciones = percepciones
      end

      horas_extras_node = nomina_node.at_xpath('//HorasExtras')
      if horas_extras_node
        horas_extras = Nomina::HorasExtras.new
        horas_extras_node.xpath('//HorasExtra').each do |horas_extra_node|
          horas_extra = Nomina::HorasExtra.new
          horas_extra.Dias = horas_extra_node.attr('Dias')
          horas_extra.HorasExtra = horas_extra_node.attr('HorasExtra')
          horas_extra.ImportePagado = horas_extra_node.attr('ImportePagado')
          horas_extra.TipoHoras = horas_extra_node.attr('TipoHoras')
          horas_extras.HorasExtras << horas_extra
        end
        nomina.HorasExtras = horas_extras
      end

      incapacidades_node = nomina_node.at_xpath('//Incapacidades')
      if incapacidades_node
        incapacidades = Nomina::Incapacidades.new
        incapacidades_node.xpath('//Incapacidad').each do |incapacidad_node|
          incapacidad = Nomina::Incapacidad.new
          incapacidad.DiasIncapacidad = incapacidad_node.attr('DiasIncapacidad')
          incapacidad.TipoIncapacidad = incapacidad_node.attr('TipoIncapacidad')
          incapacidad.Descuento = incapacidad_node.attr('Descuento')
          incapacidades.Incapacidades << incapacidad
        end
        nomina.Incapacidades = incapacidades
      end

      factura.nomina = nomina

    end

    factura

  end

end
