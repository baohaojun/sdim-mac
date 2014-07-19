# -*- coding: utf-8 -*-
# vim:et sts=4 sw=4
#
# ibus-sdim - The Tables engine for IBus
#
# Copyright (c) 2008-2009 Yu Yuwei <acevery@gmail.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#
# $Id: $
#
__all__ = (
    "tabengine",
)

def _str_percent_decode(str):
    return str.replace("%20", " ").replace("%25", "%")


import os
import sys
#from ibus import Property
import keysyms
import modifier
import re

from socket import *

class KeyEvent:
    all_mods = [
        '', #no modifier
        'A', # alt
        'AC',# alt ctrl
        'ACS', #alt ctrl shift
        'AS',
        'C',
        'CS',
        'S'
        ]
    def __init__(self, keyval, chars, state):
        self.code = keyval
        self.mask = state
        self.name = chars
        
        if self.name and not (len(self.name) == 1 and ord(self.name) < ord(' ')):
            if self.name == ' ':
                self.name = 'space'
            else:
                self.mask &= ~modifier.SHIFT_MASK
        else:
            self.name = keysyms.keycode_to_name(self.code).lower()
        
        if self.name in ("control_l",
                         "control_r",
                         "alt_l",
                         "alt_r",
                         "shift_l",
                         "shift_r",
                         ):
            self.name = ""
            return

        mods = ''
        if self.mask & modifier.ALT_MASK:
            mods += 'A'
        if self.mask & modifier.CONTROL_MASK:
            mods += 'C'
        if self.mask & modifier.SHIFT_MASK:
            mods += 'S'

        if mods != '':
            self.name = mods + ' ' + self.name
    def __str__(self):
        return self.name


class tabengine ():
    '''The IM Engine for Tables'''

    _page_size = 10

    def __init__ (self):
        self.sock = socket(AF_INET, SOCK_STREAM)
        self.sock.connect(("localhost", 31415))
        self.sock = self.sock.makefile("rwb", 0)

        self.clear_data()
        # self._lookup_table = ibus.LookupTable (tabengine._page_size)

        self._name = 'sdim'
        self._config_section = "engine/%s" % self._name
        
        # config module
        self._on = True
        

    def clear_data(self):
        self._preedit_str = ''
        self._cands = []
        self._aux_str = ''
        self._commit_str = ''
        self._cands_str = ''
        self._cand_idx = '0'
        self._active = ''

    def reset (self):
        self._update_ui ()
        pass
    
    def _update_preedit (self):
        '''Update Preedit String in UI'''
        _str = self._preedit_str
        sdim_ui.update_preedit_text(_str)
    
    def _update_aux (self):
        '''Update Aux String in UI'''
        _aux = self._aux_str
        if _aux:
            sdim_ui.update_auxiliary_text(_aux)
        else:
            sdim_ui.hide_auxiliary_text()


    def _update_lookup_table (self):
        '''Update Lookup Sdim in UI'''
        if self._cands_str == '':
            sdim_ui.hide_lookup_table()
            return

        _cands = self._cands_str.split()
        _cands = [_str_percent_decode(str) for str in _cands]
        
        sdim_ui.clear_lookup_table()

        for cand in _cands:
            sdim_ui.append_candidate(cand)
            pass

        index = int(self._cand_idx) % 10
        sdim_ui.set_cursor_pos_in_current_page(index)
        sdim_ui.update_lookup_table()

    def _update_ui (self):
        '''Update User Interface'''
        self._update_lookup_table ()
        self._update_preedit ()
        self._update_aux ()
        self.commit_string()

    def commit_string (self):
        if self._commit_str == '':
            return
        commit = self._commit_str
        self._commit_str = ''
        sdim_ui.commit_text(commit)

    def process_key_event(self, keyval, chars, state):
        '''Process Key Events
        Key Events include Key Press and Key Release,
        modifier means Key Pressed
        '''
        key = KeyEvent(keyval, chars, state)
        # ignore NumLock mask

        result = self._process_key_event (key)
        return result

    def _process_key_event (self, key):
        '''Internal method to process key event'''
        key = str(key)
        if key == '':
            return False
        if self._preedit_str == '' and len(key) != 1:
            return False
        self._really_process_key(key)
        self._update_ui()
        return True

    def _really_process_key (self, key):
        self.sock.write("keyed " + key + "\n")
        self.clear_data()
        while True:
            line = self.sock.readline()
            if not line:
                break
            line = line[:-1]
            
            if line.find('commit: ') == 0:
                self._commit_str = line[len('commit: '):]
            
            elif line.find('hint: ') == 0:
                self._aux_str = line[len('hint: '):]
            
            elif line.find('comp: ') == 0:
                self._preedit_str = line[len('comp: '):]

            elif line.find('cands: ') == 0:
                self._cands_str = line[len('cands: '):]

            elif line.find('cand_index: ') == 0:
                self._cand_idx = line[len('cand_index: '):]

            elif line.find('active: ') == 0:
                self._active = line[len('active: '):]
            
            elif line == "end:":
                break
            
            else:
                self._aux_str = line
                
    def focus_in (self):
        if self._on:
            self._update_ui ()
    
    def focus_out (self):
        pass

    def enable (self):
        self._on = True
        self.focus_in()

    def disable (self):
        self.reset()
        self._on = False

