--[[
    Happy Talks - spoken alerts for Ashita v4 (CatsEyeXI).

    Says something when you get a tell, a GM tell, a party or alliance invite, a trade, an emote
    at you, someone checks you, your bags are full, you skill up, or someone says your name.
    34 voice packs: plain voices, accents, comedy, sing-along, quotes, a movie trailer and more.

    Based on chatmon by atom0s (Ashita Development Team, GNU GPL v3) - the same events, read the
    same way. Voices made with Kokoro TTS. Unload chatmon when using this, or you'll hear both.

    Commands
      /happytalks         open the window (minimise or close it to hide it again)
      /talks on | off   (/talks works as a short name too)     all alerts on or off
      /talks pack <name>  pick a voice pack (e.g. /talks pack pirate)
      /talks test <alert> play one (tell, gm, invite, trade, emote, examined, bags, skillup, name)
]]

addon.name    = 'happytalks';
addon.author  = 'Happyfists';
addon.version = '1.2';
addon.desc    = 'Spoken alerts for tells, invites, trades and more, with 34 voice packs.';
addon.link    = 'https://github.com/Happyfists/happytalks';

require('common');
local imgui    = require('imgui');
local settings = require('settings');
local talks    = require('talks');

local s = settings.load(T{
    show      = true,
    talk_on   = true,
    talk_pack = 'heart',
}, 'happytalks');
talks.settings = s;
local opts;
settings.register('happytalks', 'happytalks_update', function (n)
    if (n ~= nil) then s = n; talks.settings = s; opts.settings = s; end
end);
local W, h = 600, 520;
local open = { s.show };
opts = { settings = s, save = nil };
local function save() settings.save('happytalks'); end
opts.save = save;

-- Black and gold, to match omni.
local function style_begin()
    imgui.PushStyleColor(ImGuiCol_WindowBg,        { 0.06, 0.06, 0.07, 0.96 });
    imgui.PushStyleColor(ImGuiCol_TitleBg,         { 0.09, 0.08, 0.06, 1.0 });
    imgui.PushStyleColor(ImGuiCol_TitleBgActive,   { 0.16, 0.13, 0.06, 1.0 });
    imgui.PushStyleColor(ImGuiCol_Border,          { 0.91, 0.73, 0.29, 0.55 });
    imgui.PushStyleColor(ImGuiCol_FrameBg,         { 0.12, 0.12, 0.13, 1.0 });
    imgui.PushStyleColor(ImGuiCol_CheckMark,       { 0.91, 0.73, 0.29, 1.0 });
    imgui.PushStyleColor(ImGuiCol_ButtonHovered,   { 0.40, 0.32, 0.14, 1.0 });
    imgui.PushStyleColor(ImGuiCol_ButtonActive,    { 0.55, 0.45, 0.18, 1.0 });
    imgui.PushStyleVar(ImGuiStyleVar_WindowRounding, 8);
    imgui.PushStyleVar(ImGuiStyleVar_FrameRounding, 4);
    imgui.PushStyleVar(ImGuiStyleVar_WindowBorderSize, 1);
end
local function style_end() imgui.PopStyleVar(3); imgui.PopStyleColor(8); end

ashita.events.register('d3d_present', 'happytalks_present', function ()
    if (not s.show) then return; end
    open[1] = true;
    imgui.SetNextWindowSize({ W, h }, ImGuiCond_Always);
    imgui.SetNextWindowCollapsed(false, ImGuiCond_Always);
    style_begin();
    local flags = bit.bor(ImGuiWindowFlags_NoResize, ImGuiWindowFlags_NoScrollbar, ImGuiWindowFlags_NoScrollWithMouse);
    local shown = imgui.Begin('Happy Talks  v' .. addon.version .. '###happytalks', open, flags);
    if (shown) then
        talks.render(opts);
        h = math.max(200, math.floor(imgui.GetCursorPosY()) + 12);
    end
    imgui.End();
    style_end();
    -- The minimise arrow or the X hides it; /happytalks brings it back.
    if (not open[1] or not shown) then s.show = false; end
end);

local function msg(t) print('\30\68[Happy Talks]\30\01 ' .. t); end

ashita.events.register('command', 'happytalks_cmd', function (e)
    local a = e.command:args();
    if (#a == 0 or (a[1]:lower() ~= '/talks' and a[1]:lower() ~= '/happytalks')) then return; end
    e.blocked = true;
    local c, v = (a[2] or ''):lower(), (a[3] or ''):lower();
    if (c == '') then
        s.show = not s.show;
    elseif (c == 'on' or c == 'off') then
        s.talk_on = (c == 'on'); save(); msg('alerts ' .. c .. '.');
    elseif (c == 'pack') then
        for _, p in ipairs(talks.PACKS) do
            if (p.id == v or p.label:lower() == v) then s.talk_pack = p.id; save(); talks.play('tell'); msg('voice: ' .. p.label); return; end
        end
        local ids = {};
        for _, p in ipairs(talks.PACKS) do ids[#ids + 1] = p.id; end
        msg('packs: ' .. table.concat(ids, ', '));
    elseif (c == 'test') then
        talks.play(v ~= '' and v or 'tell');
    else
        msg('/happytalks  |  /talks on|off  |  /talks pack <name>  |  /talks test <alert>');
    end
end);

ashita.events.register('load', 'happytalks_load', function ()
    s.show = false;
    msg('loaded. Type /happytalks to pick a voice.');
end);
