classdef reference_handle < handle
	properties
		data
	end
	methods
		function h = reference_handle(data)
		  h.data = data	;
		end
	end
end