<cfcomponent output="false">
    
    <cffunction name="init" access="public" output="false" returntype="any">
        <cfreturn this />
    </cffunction>

    <cffunction name="deflate" access="public" output="false" returntype="any">
        <cfargument name="string" type="string" required="true" />
        <cfargument name="encoding" type="string" required="false" default="" />
        <cfscript>
            var loc = {};

            loc.text = CreateObject("java", "java.lang.String").init(arguments.string);
            loc.data = CreateObject("java", "java.io.ByteArrayOutputStream").init();
            loc.comp = createObject("java", "java.util.zip.GZIPOutputStream").init(loc.data);
            
            loc.comp.write(loc.text.getBytes());
            loc.comp.finish();
            loc.comp.close();

            if (Len(arguments.encoding))
                return BinaryEncode(loc.data.toByteArray(), arguments.encoding);
        </cfscript>
        <cfreturn loc.data.toByteArray() />
    </cffunction>

    <cffunction name="inflate" access="public" output="false" returntype="string">
        <cfargument name="object" type="any" required="true" />
        <cfargument name="encoding" type="string" required="false" default="" />
        <cfscript>
            var loc = { bufferSize = 8192, counter = 0 };

            loc.byteArray = CreateObject("java", "java.lang.reflect.Array").newInstance(CreateObject("java", "java.lang.Byte").TYPE, loc.bufferSize);
            loc.outStream = CreateObject("java", "java.io.ByteArrayOutputStream").init();

            if (!IsBinary(arguments.object) and !Len(arguments.encoding))
                return;

            if (Len(arguments.encoding))
                arguments.object = BinaryDecode(arguments.object, arguments.encoding);

            loc.decStream = CreateObject("java", "java.util.zip.GZIPInputStream").init(CreateObject("java", "java.io.ByteArrayInputStream").init(arguments.object));

            loc.counter = loc.decStream.read(loc.byteArray, 0, loc.bufferSize);

            while (loc.counter gt -1)
            {
                loc.outStream.write(loc.byteArray, 0, loc.counter);
                loc.counter = loc.decStream.read(loc.byteArray, 0, loc.bufferSize);
            }

            loc.decStream.close();
            loc.outStream.close();
        </cfscript>
        <cfreturn loc.outStream.toString() />
    </cffunction>

</cfcomponent>