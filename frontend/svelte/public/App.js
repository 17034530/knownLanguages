'use strict';

function noop() { }
// Adapted from https://github.com/then/is-promise/blob/master/index.js
// Distributed under MIT License https://github.com/then/is-promise/blob/master/LICENSE
function is_promise(value) {
    return !!value && (typeof value === 'object' || typeof value === 'function') && typeof value.then === 'function';
}
function run(fn) {
    return fn();
}
function blank_object() {
    return Object.create(null);
}
function run_all(fns) {
    fns.forEach(run);
}
function is_function(thing) {
    return typeof thing === 'function';
}
function safe_not_equal(a, b) {
    return a != a ? b == b : a !== b || ((a && typeof a === 'object') || typeof a === 'function');
}
function subscribe(store, ...callbacks) {
    if (store == null) {
        return noop;
    }
    const unsub = store.subscribe(...callbacks);
    return unsub.unsubscribe ? () => unsub.unsubscribe() : unsub;
}

let current_component;
function set_current_component(component) {
    current_component = component;
}
function get_current_component() {
    if (!current_component)
        throw new Error('Function called outside component initialization');
    return current_component;
}
/**
 * The `onMount` function schedules a callback to run as soon as the component has been mounted to the DOM.
 * It must be called during the component's initialisation (but doesn't need to live *inside* the component;
 * it can be called from an external module).
 *
 * `onMount` does not run inside a [server-side component](/docs#run-time-server-side-component-api).
 *
 * https://svelte.dev/docs#run-time-svelte-onmount
 */
function onMount(fn) {
    get_current_component().$$.on_mount.push(fn);
}
/**
 * Schedules a callback to run immediately before the component is unmounted.
 *
 * Out of `onMount`, `beforeUpdate`, `afterUpdate` and `onDestroy`, this is the
 * only one that runs inside a server-side component.
 *
 * https://svelte.dev/docs#run-time-svelte-ondestroy
 */
function onDestroy(fn) {
    get_current_component().$$.on_destroy.push(fn);
}
/**
 * Associates an arbitrary `context` object with the current component and the specified `key`
 * and returns that object. The context is then available to children of the component
 * (including slotted content) with `getContext`.
 *
 * Like lifecycle functions, this must be called during component initialisation.
 *
 * https://svelte.dev/docs#run-time-svelte-setcontext
 */
function setContext(key, context) {
    get_current_component().$$.context.set(key, context);
    return context;
}
/**
 * Retrieves the context that belongs to the closest parent component with the specified `key`.
 * Must be called during component initialisation.
 *
 * https://svelte.dev/docs#run-time-svelte-getcontext
 */
function getContext(key) {
    return get_current_component().$$.context.get(key);
}
const missing_component = {
    $$render: () => ''
};
function validate_component(component, name) {
    if (!component || !component.$$render) {
        if (name === 'svelte:component')
            name += ' this={...}';
        throw new Error(`<${name}> is not a valid SSR component. You may need to review your build config to ensure that dependencies are compiled, rather than imported as pre-compiled modules. Otherwise you may need to fix a <${name}>.`);
    }
    return component;
}
let on_destroy;
function create_ssr_component(fn) {
    function $$render(result, props, bindings, slots, context) {
        const parent_component = current_component;
        const $$ = {
            on_destroy,
            context: new Map(context || (parent_component ? parent_component.$$.context : [])),
            // these will be immediately discarded
            on_mount: [],
            before_update: [],
            after_update: [],
            callbacks: blank_object()
        };
        set_current_component({ $$ });
        const html = fn(result, props, bindings, slots);
        set_current_component(parent_component);
        return html;
    }
    return {
        render: (props = {}, { $$slots = {}, context = new Map() } = {}) => {
            on_destroy = [];
            const result = { title: '', head: '', css: new Set() };
            const html = $$render(result, props, {}, $$slots, context);
            run_all(on_destroy);
            return {
                html,
                css: {
                    code: Array.from(result.css).map(css => css.code).join('\n'),
                    map: null // TODO
                },
                head: result.title + result.head
            };
        },
        $$render
    };
}

const LOCATION = {};
const ROUTER = {};
const HISTORY = {};

/**
 * Adapted from https://github.com/reach/router/blob/b60e6dd781d5d3a4bdaaf4de665649c0f6a7e78d/src/lib/utils.js
 * https://github.com/reach/router/blob/master/LICENSE
 */

const PARAM = /^:(.+)/;
const SEGMENT_POINTS = 4;
const STATIC_POINTS = 3;
const DYNAMIC_POINTS = 2;
const SPLAT_PENALTY = 1;
const ROOT_POINTS = 1;

/**
 * Split up the URI into segments delimited by `/`
 * Strip starting/ending `/`
 * @param {string} uri
 * @return {string[]}
 */
const segmentize = (uri) => uri.replace(/(^\/+|\/+$)/g, "").split("/");
/**
 * Strip `str` of potential start and end `/`
 * @param {string} string
 * @return {string}
 */
const stripSlashes = (string) => string.replace(/(^\/+|\/+$)/g, "");
/**
 * Score a route depending on how its individual segments look
 * @param {object} route
 * @param {number} index
 * @return {object}
 */
const rankRoute = (route, index) => {
    const score = route.default
        ? 0
        : segmentize(route.path).reduce((score, segment) => {
              score += SEGMENT_POINTS;

              if (segment === "") {
                  score += ROOT_POINTS;
              } else if (PARAM.test(segment)) {
                  score += DYNAMIC_POINTS;
              } else if (segment[0] === "*") {
                  score -= SEGMENT_POINTS + SPLAT_PENALTY;
              } else {
                  score += STATIC_POINTS;
              }

              return score;
          }, 0);

    return { route, score, index };
};
/**
 * Give a score to all routes and sort them on that
 * If two routes have the exact same score, we go by index instead
 * @param {object[]} routes
 * @return {object[]}
 */
const rankRoutes = (routes) =>
    routes
        .map(rankRoute)
        .sort((a, b) =>
            a.score < b.score ? 1 : a.score > b.score ? -1 : a.index - b.index
        );
/**
 * Ranks and picks the best route to match. Each segment gets the highest
 * amount of points, then the type of segment gets an additional amount of
 * points where
 *
 *  static > dynamic > splat > root
 *
 * This way we don't have to worry about the order of our routes, let the
 * computers do it.
 *
 * A route looks like this
 *
 *  { path, default, value }
 *
 * And a returned match looks like:
 *
 *  { route, params, uri }
 *
 * @param {object[]} routes
 * @param {string} uri
 * @return {?object}
 */
const pick = (routes, uri) => {
    let match;
    let default_;

    const [uriPathname] = uri.split("?");
    const uriSegments = segmentize(uriPathname);
    const isRootUri = uriSegments[0] === "";
    const ranked = rankRoutes(routes);

    for (let i = 0, l = ranked.length; i < l; i++) {
        const route = ranked[i].route;
        let missed = false;

        if (route.default) {
            default_ = {
                route,
                params: {},
                uri,
            };
            continue;
        }

        const routeSegments = segmentize(route.path);
        const params = {};
        const max = Math.max(uriSegments.length, routeSegments.length);
        let index = 0;

        for (; index < max; index++) {
            const routeSegment = routeSegments[index];
            const uriSegment = uriSegments[index];

            if (routeSegment && routeSegment[0] === "*") {
                // Hit a splat, just grab the rest, and return a match
                // uri:   /files/documents/work
                // route: /files/* or /files/*splatname
                const splatName =
                    routeSegment === "*" ? "*" : routeSegment.slice(1);

                params[splatName] = uriSegments
                    .slice(index)
                    .map(decodeURIComponent)
                    .join("/");
                break;
            }

            if (typeof uriSegment === "undefined") {
                // URI is shorter than the route, no match
                // uri:   /users
                // route: /users/:userId
                missed = true;
                break;
            }

            const dynamicMatch = PARAM.exec(routeSegment);

            if (dynamicMatch && !isRootUri) {
                const value = decodeURIComponent(uriSegment);
                params[dynamicMatch[1]] = value;
            } else if (routeSegment !== uriSegment) {
                // Current segments don't match, not dynamic, not splat, so no match
                // uri:   /users/123/settings
                // route: /users/:id/profile
                missed = true;
                break;
            }
        }

        if (!missed) {
            match = {
                route,
                params,
                uri: "/" + uriSegments.slice(0, index).join("/"),
            };
            break;
        }
    }

    return match || default_ || null;
};
/**
 * Combines the `basepath` and the `path` into one path.
 * @param {string} basepath
 * @param {string} path
 */
const combinePaths = (basepath, path) =>
    `${stripSlashes(
        path === "/"
            ? basepath
            : `${stripSlashes(basepath)}/${stripSlashes(path)}`
    )}/`;

const canUseDOM = () =>
    typeof window !== "undefined" &&
    "document" in window &&
    "location" in window;

/* node_modules/svelte-routing/src/Route.svelte generated by Svelte v3.59.2 */

const Route = create_ssr_component(($$result, $$props, $$bindings, slots) => {
	let $activeRoute, $$unsubscribe_activeRoute;
	let { path = "" } = $$props;
	let { component = null } = $$props;
	let routeParams = {};
	let routeProps = {};
	const { registerRoute, unregisterRoute, activeRoute } = getContext(ROUTER);
	$$unsubscribe_activeRoute = subscribe(activeRoute, value => $activeRoute = value);

	const route = {
		path,
		// If no path prop is given, this Route will act as the default Route
		// that is rendered if no other Route in the Router is a match.
		default: path === ""
	};

	registerRoute(route);

	onDestroy(() => {
		unregisterRoute(route);
	});

	if ($$props.path === void 0 && $$bindings.path && path !== void 0) $$bindings.path(path);
	if ($$props.component === void 0 && $$bindings.component && component !== void 0) $$bindings.component(component);

	{
		if ($activeRoute && $activeRoute.route === route) {
			routeParams = $activeRoute.params;
			const { component: c, path, ...rest } = $$props;
			routeProps = rest;

			if (c) {
				if (c.toString().startsWith("class ")) component = c; else component = c();
			}

			canUseDOM() && window?.scrollTo(0, 0);
		}
	}

	$$unsubscribe_activeRoute();

	return `${$activeRoute && $activeRoute.route === route
	? `${component
		? `${(function (__value) {
				if (is_promise(__value)) {
					__value.then(null, noop);
					return ``;
				}

				return (function (resolvedComponent) {
					return `
            ${validate_component(resolvedComponent?.default || resolvedComponent || missing_component, "svelte:component").$$render($$result, Object.assign({}, routeParams, routeProps), {}, {})}
        `;
				})(__value);
			})(component)}`
		: `${slots.default
			? slots.default({ params: routeParams })
			: ``}`}`
	: ``}`;
});

const subscriber_queue = [];
/**
 * Creates a `Readable` store that allows reading by subscription.
 * @param value initial value
 * @param {StartStopNotifier} [start]
 */
function readable(value, start) {
    return {
        subscribe: writable(value, start).subscribe
    };
}
/**
 * Create a `Writable` store that allows both updating and reading by subscription.
 * @param {*=}value initial value
 * @param {StartStopNotifier=} start
 */
function writable(value, start = noop) {
    let stop;
    const subscribers = new Set();
    function set(new_value) {
        if (safe_not_equal(value, new_value)) {
            value = new_value;
            if (stop) { // store is ready
                const run_queue = !subscriber_queue.length;
                for (const subscriber of subscribers) {
                    subscriber[1]();
                    subscriber_queue.push(subscriber, value);
                }
                if (run_queue) {
                    for (let i = 0; i < subscriber_queue.length; i += 2) {
                        subscriber_queue[i][0](subscriber_queue[i + 1]);
                    }
                    subscriber_queue.length = 0;
                }
            }
        }
    }
    function update(fn) {
        set(fn(value));
    }
    function subscribe(run, invalidate = noop) {
        const subscriber = [run, invalidate];
        subscribers.add(subscriber);
        if (subscribers.size === 1) {
            stop = start(set) || noop;
        }
        run(value);
        return () => {
            subscribers.delete(subscriber);
            if (subscribers.size === 0 && stop) {
                stop();
                stop = null;
            }
        };
    }
    return { set, update, subscribe };
}
function derived(stores, fn, initial_value) {
    const single = !Array.isArray(stores);
    const stores_array = single
        ? [stores]
        : stores;
    const auto = fn.length < 2;
    return readable(initial_value, (set) => {
        let started = false;
        const values = [];
        let pending = 0;
        let cleanup = noop;
        const sync = () => {
            if (pending) {
                return;
            }
            cleanup();
            const result = fn(single ? values[0] : values, set);
            if (auto) {
                set(result);
            }
            else {
                cleanup = is_function(result) ? result : noop;
            }
        };
        const unsubscribers = stores_array.map((store, i) => subscribe(store, (value) => {
            values[i] = value;
            pending &= ~(1 << i);
            if (started) {
                sync();
            }
        }, () => {
            pending |= (1 << i);
        }));
        started = true;
        sync();
        return function stop() {
            run_all(unsubscribers);
            cleanup();
            // We need to set this to false because callbacks can still happen despite having unsubscribed:
            // Callbacks might already be placed in the queue which doesn't know it should no longer
            // invoke this derived store.
            started = false;
        };
    });
}

/**
 * Adapted from https://github.com/reach/router/blob/b60e6dd781d5d3a4bdaaf4de665649c0f6a7e78d/src/lib/history.js
 * https://github.com/reach/router/blob/master/LICENSE
 */

const getLocation = (source) => {
    return {
        ...source.location,
        state: source.history.state,
        key: (source.history.state && source.history.state.key) || "initial",
    };
};
const createHistory = (source) => {
    const listeners = [];
    let location = getLocation(source);

    return {
        get location() {
            return location;
        },

        listen(listener) {
            listeners.push(listener);

            const popstateListener = () => {
                location = getLocation(source);
                listener({ location, action: "POP" });
            };

            source.addEventListener("popstate", popstateListener);

            return () => {
                source.removeEventListener("popstate", popstateListener);
                const index = listeners.indexOf(listener);
                listeners.splice(index, 1);
            };
        },

        navigate(to, { state, replace = false } = {}) {
            state = { ...state, key: Date.now() + "" };
            // try...catch iOS Safari limits to 100 pushState calls
            try {
                if (replace) source.history.replaceState(state, "", to);
                else source.history.pushState(state, "", to);
            } catch (e) {
                source.location[replace ? "replace" : "assign"](to);
            }
            location = getLocation(source);
            listeners.forEach((listener) =>
                listener({ location, action: "PUSH" })
            );
            document.activeElement.blur();
        },
    };
};
// Stores history entries in memory for testing or other platforms like Native
const createMemorySource = (initialPathname = "/") => {
    let index = 0;
    const stack = [{ pathname: initialPathname, search: "" }];
    const states = [];

    return {
        get location() {
            return stack[index];
        },
        addEventListener(name, fn) {},
        removeEventListener(name, fn) {},
        history: {
            get entries() {
                return stack;
            },
            get index() {
                return index;
            },
            get state() {
                return states[index];
            },
            pushState(state, _, uri) {
                const [pathname, search = ""] = uri.split("?");
                index++;
                stack.push({ pathname, search });
                states.push(state);
            },
            replaceState(state, _, uri) {
                const [pathname, search = ""] = uri.split("?");
                stack[index] = { pathname, search };
                states[index] = state;
            },
        },
    };
};
// Global history uses window.history as the source if available,
// otherwise a memory history
const globalHistory = createHistory(
    canUseDOM() ? window : createMemorySource()
);

/* node_modules/svelte-routing/src/Router.svelte generated by Svelte v3.59.2 */

const Router = create_ssr_component(($$result, $$props, $$bindings, slots) => {
	let $location, $$unsubscribe_location;
	let $routes, $$unsubscribe_routes;
	let $base, $$unsubscribe_base;
	let $activeRoute, $$unsubscribe_activeRoute;
	let { basepath = "/" } = $$props;
	let { url = null } = $$props;
	let { history = globalHistory } = $$props;
	setContext(HISTORY, history);
	const locationContext = getContext(LOCATION);
	const routerContext = getContext(ROUTER);
	const routes = writable([]);
	$$unsubscribe_routes = subscribe(routes, value => $routes = value);
	const activeRoute = writable(null);
	$$unsubscribe_activeRoute = subscribe(activeRoute, value => $activeRoute = value);
	let hasActiveRoute = false; // Used in SSR to synchronously set that a Route is active.

	// If locationContext is not set, this is the topmost Router in the tree.
	// If the `url` prop is given we force the location to it.
	const location = locationContext || writable(url ? { pathname: url } : history.location);

	$$unsubscribe_location = subscribe(location, value => $location = value);

	// If routerContext is set, the routerBase of the parent Router
	// will be the base for this Router's descendants.
	// If routerContext is not set, the path and resolved uri will both
	// have the value of the basepath prop.
	const base = routerContext
	? routerContext.routerBase
	: writable({ path: basepath, uri: basepath });

	$$unsubscribe_base = subscribe(base, value => $base = value);

	const routerBase = derived([base, activeRoute], ([base, activeRoute]) => {
		// If there is no activeRoute, the routerBase will be identical to the base.
		if (!activeRoute) return base;

		const { path: basepath } = base;
		const { route, uri } = activeRoute;

		// Remove the potential /* or /*splatname from
		// the end of the child Routes relative paths.
		const path = route.default
		? basepath
		: route.path.replace(/\*.*$/, "");

		return { path, uri };
	});

	const registerRoute = route => {
		const { path: basepath } = $base;
		let { path } = route;

		// We store the original path in the _path property so we can reuse
		// it when the basepath changes. The only thing that matters is that
		// the route reference is intact, so mutation is fine.
		route._path = path;

		route.path = combinePaths(basepath, path);

		if (typeof window === "undefined") {
			// In SSR we should set the activeRoute immediately if it is a match.
			// If there are more Routes being registered after a match is found,
			// we just skip them.
			if (hasActiveRoute) return;

			const matchingRoute = pick([route], $location.pathname);

			if (matchingRoute) {
				activeRoute.set(matchingRoute);
				hasActiveRoute = true;
			}
		} else {
			routes.update(rs => [...rs, route]);
		}
	};

	const unregisterRoute = route => {
		routes.update(rs => rs.filter(r => r !== route));
	};

	if (!locationContext) {
		// The topmost Router in the tree is responsible for updating
		// the location store and supplying it through context.
		onMount(() => {
			const unlisten = history.listen(event => {
				location.set(event.location);
			});

			return unlisten;
		});

		setContext(LOCATION, location);
	}

	setContext(ROUTER, {
		activeRoute,
		base,
		routerBase,
		registerRoute,
		unregisterRoute
	});

	if ($$props.basepath === void 0 && $$bindings.basepath && basepath !== void 0) $$bindings.basepath(basepath);
	if ($$props.url === void 0 && $$bindings.url && url !== void 0) $$bindings.url(url);
	if ($$props.history === void 0 && $$bindings.history && history !== void 0) $$bindings.history(history);

	{
		{
			const { path: basepath } = $base;
			routes.update(rs => rs.map(r => Object.assign(r, { path: combinePaths(basepath, r._path) })));
		}
	}

	{
		{
			const bestMatch = pick($routes, $location.pathname);
			activeRoute.set(bestMatch);
		}
	}

	$$unsubscribe_location();
	$$unsubscribe_routes();
	$$unsubscribe_base();
	$$unsubscribe_activeRoute();

	return `${slots.default
	? slots.default({
			route: $activeRoute && $activeRoute.uri,
			location: $location
		})
	: ``}`;
});

/* src/page/Loading.svelte generated by Svelte v3.59.2 */

const Loading = create_ssr_component(($$result, $$props, $$bindings, slots) => {
	return `<main><h1>LOADING PLEASE WAIT</h1></main>`;
});

/* src/page/NotFound.svelte generated by Svelte v3.59.2 */

const NotFound = create_ssr_component(($$result, $$props, $$bindings, slots) => {
	return `<main><h2>Page not found</h2>
  <button>Back</button></main>`;
});

/* src/page/login.svelte generated by Svelte v3.59.2 */

const Login = create_ssr_component(($$result, $$props, $$bindings, slots) => {

	return `<main><div class="centerDiv"><label class="forTitle" for="">Login</label>
    <form class="info"><div class="form-group"><label for="name" class="text-muted mb-1">Name:
        </label>
        <input id="name" name="name" class="form-control" type="text" placeholder="Name" autocomplete="off"></div>
      <div class="form-group"><label for="password" class="text-muted mb-1">Password:
        </label>
        <input id="password" name="password" class="form-control" type="password" placeholder="Password"></div>
      <button type="submit" class="infoButton2 py-3 mt-4 btn btn-lg btn-success btn-block">Login
      </button>
      <button type="button" class="infoButton2 py-3 mt-4 btn btn-lg btn-success btn-block">Sign Up
      </button></form></div>
</main>`;
});

/* src/page/Create.svelte generated by Svelte v3.59.2 */

const Create = create_ssr_component(($$result, $$props, $$bindings, slots) => {
	return `<main><h1>Create</h1></main>`;
});

/* src/page/Home.svelte generated by Svelte v3.59.2 */

const Home = create_ssr_component(($$result, $$props, $$bindings, slots) => {
	return `<main><h1>HOME</h1></main>`;
});

/* src/page/Profile.svelte generated by Svelte v3.59.2 */

const Profile = create_ssr_component(($$result, $$props, $$bindings, slots) => {
	return `<main><h1>Profile</h1></main>`;
});

/* src/App.svelte generated by Svelte v3.59.2 */

const App = create_ssr_component(($$result, $$props, $$bindings, slots) => {
	let loaded = true;
	let loggedIn = false;
	let { url = "" } = $$props;

	// onMount(()=>{
	let token = sessionStorage.getItem("token");

	if (token) {
		loaded = true;
		loggedIn = true;
	} else {
		loaded = true;
	}

	if ($$props.url === void 0 && $$bindings.url && url !== void 0) $$bindings.url(url);

	return `${validate_component(Router, "Router").$$render($$result, { url }, {}, {
		default: () => {
			return `${loaded
			? `${loggedIn
				? `${validate_component(Route, "Route").$$render($$result, { path: "/", component: Home }, {}, {})}
			${validate_component(Route, "Route").$$render($$result, { path: "/profile", component: Profile }, {}, {})}
			${validate_component(Route, "Route").$$render($$result, { component: NotFound }, {}, {})}`
				: `${validate_component(Route, "Route").$$render($$result, { path: "/", component: Login }, {}, {})}
			${validate_component(Route, "Route").$$render($$result, { path: "/create", component: Create }, {}, {})}
			${validate_component(Route, "Route").$$render($$result, { component: NotFound }, {}, {})}`}`
			: `${validate_component(Route, "Route").$$render($$result, { component: Loading }, {}, {})}`}`;
		}
	})}`;
});

module.exports = App;
