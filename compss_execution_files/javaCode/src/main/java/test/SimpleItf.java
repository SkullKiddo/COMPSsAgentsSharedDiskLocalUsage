package test;

import es.bsc.compss.types.annotations.Parameter;
import es.bsc.compss.types.annotations.parameter.Direction;
import es.bsc.compss.types.annotations.parameter.Type;
import es.bsc.compss.types.annotations.task.Method;


public interface SimpleItf {

    @Method(declaringClass = "test.Simple")
    void tarea(@Parameter(type = Type.OBJECT, direction = Direction.INOUT) Object obj);

}
