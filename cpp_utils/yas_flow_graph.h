//
//  yas_flow_graph.h
//

#pragma once

#include "yas_base.h"
#include "yas_types.h"

namespace yas::flow {
template <typename Waiting>
struct wait {
    Waiting waiting;
};

template <typename Running, typename Event>
struct run {
    Running running;
    Event const &event;
};

struct stay {};

enum class state_kind { waiting, running };

template <typename Waiting, typename Running>
struct state {
    state(Waiting);
    state(Running);

    state_kind kind() const;

    Waiting const &waiting() const;
    Running const &running() const;

   private:
    std::optional<Waiting> _waiting;
    std::optional<Running> _running;
};

struct waiting_out : base {
    template <typename Waiting>
    waiting_out(flow::wait<Waiting>);

    template <typename Running, typename Event>
    waiting_out(flow::run<Running, Event>);

    waiting_out(flow::stay);

    waiting_out(std::nullptr_t);

    enum class kind { wait, run, stay };

    template <typename Waiting, typename Running, typename Event>
    kind kind() const;

    template <typename Waiting>
    wait<Waiting> wait() const;

    template <typename Running, typename Event>
    run<Running, Event> run() const;
};

struct running_out : base {
    template <typename Waiting>
    running_out(flow::wait<Waiting>);

    template <typename Running, typename Event>
    running_out(flow::run<Running, Event>);

    running_out(std::nullptr_t);

    enum class kind { wait, run };

    template <typename Waiting, typename Running, typename Event>
    kind kind() const;

    template <typename Waiting>
    wait<Waiting> wait() const;

    template <typename Running, typename Event>
    run<Running, Event> run() const;
};

template <typename Waiting, typename Running, typename Event>
struct waiting_signal {
    Event const &event;

    waiting_out wait(Waiting waiting) const {
        return waiting_out(flow::wait<Waiting>{std::move(waiting)});
    }

    waiting_out run(Running running, Event const &event) const {
        return waiting_out(flow::run<Running, Event>{std::move(running), event});
    }

    waiting_out stay() const {
        return waiting_out{flow::stay{}};
    }
};

template <typename Waiting, typename Running, typename Event>
struct running_signal {
    Event const &event;

    running_out wait(Waiting state) const {
        return running_out{flow::wait<Waiting>{state}};
    }

    running_out run(Running running, Event const &event) const {
        return running_out{flow::run<Running, Event>{std::move(running), event}};
    }
};

template <typename Waiting, typename Running, typename Event>
struct graph : base {
    class impl;

    using waiting_signal_t = waiting_signal<Waiting, Running, Event>;
    using running_signal_t = running_signal<Waiting, Running, Event>;
    using waiting_handler_f = std::function<waiting_out(waiting_signal_t const &)>;
    using running_handler_f = std::function<running_out(running_signal_t const &)>;

    graph(Waiting);
    graph(std::nullptr_t);

    void add_waiting(Waiting, waiting_handler_f);
    void add_running(Running, running_handler_f);

    void run(Event const &);

    state<Waiting, Running> const &current() const;

    bool contains(state<Waiting, Running> const &) const;
};
}  // namespace yas::flow

#include "yas_flow_graph_private.h"
