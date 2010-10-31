/*  Part of SWI-Prolog

    Author:        Jan Wielemaker
    E-mail:        J.Wielemaker@cs.vu.nl
    WWW:           http://www.swi-prolog.org
    Copyright (C): 2002-2010, University of Amsterdam
			      Vu University Amsterdam

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    As a special exception, if you link this library with other files,
    compiled with a Free Software compiler, to produce an executable, this
    library does not by itself cause the resulting executable to be covered
    by the GNU General Public License. This exception does not however
    invalidate any other reasons why the executable file might be covered by
    the GNU General Public License.
*/

:- module(files_ex,
	  [ set_time_file/3,		% +File, -OldTimes, +NewTimes
	    link_file/3,		% +OldPath, +NewPath, +Type
	    relative_file_name/3	% +AbsPath, +RelTo, -RelPath
	  ]).

/** <module> Extended operations on files
*/

:- use_foreign_library(foreign(files), install_files).

%%	set_time_file(+File, -OldTimes, +NewTimes) is det.
%
%	Query and set POSIX time attributes of a file. Both OldTimes and
%	NewTimes are lists of  option-terms.   Times  are represented in
%	SWI-Prolog's standard floating point numbers.   New times may be
%	specified as =now= to indicate the current time. Defined options
%	are:
%
%	    * access(Time)
%	    Describes the time of last access   of  the file. This value
%	    can be read and written.
%
%	    * modified(Time)
%	    Describes the time  the  contents  of   the  file  was  last
%	    modified. This value can be read and written.
%
%	    * changed(Time)
%	    Describes the time the file-structure  itself was changed by
%	    adding (link()) or removing (unlink()) names.
%
%	Below  are  some  example  queries.   The  first  retrieves  the
%	access-time, while the second sets the last-modified time to the
%	current time.
%
%	    ==
%	    ?- set_time_file(foo, [acess(Access)], []).
%	    ?- set_time_file(foo, [], [modified(now)]).
%	    ==

%%	link_file(+OldPath, +NewPath, +Type) is det.
%
%	Create a link in the filesystem   from  NewPath to OldPath. Type
%	defines the type of link and is one of =hard= or =symbolic=.

%%	relative_file_name(+AbsPath:atom, +RelTo:atom, -RelPath:atom) is det.
%
%	True when RelPath is a relative path to AbsPath, relative to
%	RelTo. For example:
%
%	==
%	?- relative_file_name('/home/janw/nice',
%			      '/home/janw/deep/dir/file', Path).
%	Path = '../../nice'.
%	==
%
%	@param	All paths must be in canonical POSIX notation, i.e.,
%		using / to separate segments in the path.  See
%		prolog_to_os_filename/2.

relative_file_name(Path, RelTo, RelPath) :-
        atomic_list_concat(PL, /, Path),
        atomic_list_concat(RL, /, RelTo),
        delete_common_prefix(PL, RL, PL1, PL2),
        to_dot_dot(PL2, DotDot, PL1),
        atomic_list_concat(DotDot, /, RelPath).

delete_common_prefix([H|T01], [H|T02], T1, T2) :- !,
        delete_common_prefix(T01, T02, T1, T2).
delete_common_prefix(T1, T2, T1, T2).

to_dot_dot([], Tail, Tail).
to_dot_dot([_], Tail, Tail) :- !.
to_dot_dot([_|T0], ['..'|T], Tail) :-
        to_dot_dot(T0, T, Tail).
