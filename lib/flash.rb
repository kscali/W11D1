require 'json'
require 'byebug'

class Flash
    attr_reader :now

    def initialize(req)
        @cookie = req.cookies['_rails_lite_app_flash']

        @flash = {}

        if @cookie
            @now = JSON.parse(@cookie)
        else
            @now = {}
        end
    end

    def []=(key, value)
        @flash[key.to_s] = value
    end

    def store_flash(res)
        # debugger
        value = @flash.merge(@now)
        res.set_cookie('_rails_lite_app_flash', {value: value.to_json, path: '/'})
    end

    def [](key)
        # debugger
        @now[key.to_s] || @flash[key.to_s]
    end

    # def now
    #     @now
    # end

end
