    function vtable_bind(module,interface,index,type)
        local addr = ffi.cast("void***", utils.find_interface(module, interface)) or error(interface..' is nil.')
        return ffi.cast(ffi.typeof(type), addr[0][index]),addr
    end
    
    function __thiscall(func, this) -- bind wrapper for __thiscall functions
        return function(...)
            return func(this, ...)
        end
    end
    
    local Matrix4x4 = ffi.cdef[[
        typedef struct {
            union {
                struct {
                    float _11, _12, _13, _14;
                    float _21, _22, _23, _24;
                    float _31, _32, _33, _34;
                    float _41, _42, _43, _44;
    
                };
                float m[4][4];
            };
        } Matrix4x4;
    ]]
    
    local nativeWorldToScreenMatrix =__thiscall(vtable_bind("engine.dll", "VEngineClient014", 37, "const Matrix4x4&(__thiscall*)(void*)"))
    
    local screenMatrix=nil
    local screen_w, screen_h = nil
    
    function clamp(min,max,value)
        return math.min(math.max(min,value),max)
    end
    
    function transformWorldPositionToScreenPosition(matrix,world_position,clamp_values)
        local w=matrix._41*world_position.x+matrix._42*world_position.y+matrix._43*world_position.z+matrix._44
        if screen_w==nil then
            screen_w, screen_h = render.get_screen_size()
        end
        if w < 0.001 then
            local mw=(matrix._11*world_position.x+matrix._12*world_position.y+matrix._13*world_position.z+matrix._14)/(w*-1)
            local mh=(matrix._21*world_position.x+matrix._22*world_position.y+matrix._23*world_position.z+matrix._24)/(w*-1)
            screen_w_ret=(screen_w/2)*(1+mw)
            screen_h_ret=(screen_h/2)*(1-mh)
            if clamp_values==true or clamp_values==nil then
                screen_w_ret=clamp(0,screen_w,screen_w_ret)
                screen_h_ret=clamp(0,screen_h,screen_h_ret)
            end
            return Vector(screen_w_ret,screen_h_ret,0)
        end
        screen_w_ret=(screen_w/2)*(1+(matrix._11*world_position.x+matrix._12*world_position.y+matrix._13*world_position.z+matrix._14)/w)
        screen_h_ret=(screen_h/2)*(1-(matrix._21*world_position.x+matrix._22*world_position.y+matrix._23*world_position.z+matrix._24)/w)
        return Vector(screen_w_ret,screen_h_ret,1)
    end
    
     
    function worldToScreen(world_position,clamp_values)
        screenMatrix=screenMatrix or nativeWorldToScreenMatrix()
        return transformWorldPositionToScreenPosition(screenMatrix,world_position,clamp_values)
    end
    
    return worldToScreen
