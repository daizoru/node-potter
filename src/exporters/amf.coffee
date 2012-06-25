
class Exporter

  constructor: ->

  save: ->

    # TODO http://en.wikipedia.org/wiki/Additive_Manufacturing_File_Format
    # resources: http://amf.wikispaces.com/
    version = "1.0"
    unit = "millimeter"

    metadata =
      description: "Production 123"
      author: "John Smith"
      copyright: "Smith & Co. 2012"
      cad: "node-potter"
      name: "foo"
      revision: "0.0.0"
    header = """
    <?xml version="#{version}"?>
      <amf unit="#{unit}">
        
        <metadata type="description">Product 123</metadata>

        ...
        <object ObjectID="0">
          <metadata type="name">Component 1</metadata>
          ...
        </object>
    </amf>
    """