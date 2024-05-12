//
//  flow_graph.h
//

#pragma once

#include <functional>
#include <optional>

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

struct out_impl_base {
    virtual ~out_impl_base() = default;
};

template <typename T>
struct out_impl : out_impl_base {
    T value;

    out_impl(T &&value) : value(std::move(value)) {
    }
};

enum class waiting_out_kind { wait, run, stay };

template <typename Waiting, typename Running, typename Event>
struct waiting_out {
    waiting_out(flow::wait<Waiting>);
    waiting_out(flow::run<Running, Event>);
    waiting_out(flow::stay);
    waiting_out(std::nullptr_t);

    waiting_out_kind kind() const;

    wait<Waiting> wait() const;

    run<Running, Event> run() const;

   private:
    std::shared_ptr<out_impl<flow::wait<Waiting>>> _wait_impl = nullptr;
    std::shared_ptr<out_impl<flow::run<Running, Event>>> _run_impl = nullptr;
    std::shared_ptr<out_impl<flow::stay>> _stay_impl = nullptr;
};

enum class running_out_kind { wait, run };

template <typename Waiting, typename Running, typename Event>
struct running_out {
    running_out(flow::wait<Waiting>);
    running_out(flow::run<Running, Event>);
    running_out(std::nullptr_t);

    running_out_kind kind() const;

    wait<Waiting> wait() const;

    run<Running, Event> run() const;

   private:
    std::shared_ptr<out_impl<flow::wait<Waiting>>> _wait_impl = nullptr;
    std::shared_ptr<out_impl<flow::run<Running, Event>>> _run_impl = nullptr;
};

template <typename Waiting, typename Running, typename Event>
struct waiting_signal {
    Event const &event;

    waiting_out<Waiting, Running, Event> wait(Waiting waiting) const {
        return waiting_out(flow::wait<Waiting>{std::move(waiting)});
    }

    waiting_out<Waiting, Running, Event> run(Running running, Event const &event) const {
        return waiting_out<Waiting, Running, Event>{flow::run<Running, Event>{std::move(running), event}};
    }

    waiting_out<Waiting, Running, Event> stay() const {
        return waiting_out<Waiting, Running, Event>{flow::stay{}};
    }
};

template <typename Waiting, typename Running, typename Event>
struct running_signal {
    Event const &event;

    running_out<Waiting, Running, Event> wait(Waiting state) const {
        return running_out<Waiting, Running, Event>{flow::wait<Waiting>{state}};
    }

    running_out<Waiting, Running, Event> run(Running running, Event const &event) const {
        return running_out<Waiting, Running, Event>{flow::run<Running, Event>{std::move(running), event}};
    }
};

template <typename Waiting, typename Running, typename Event>
struct graph final {
    using waiting_signal_t = waiting_signal<Waiting, Running, Event>;
    using running_signal_t = running_signal<Waiting, Running, Event>;
    using waiting_handler_f = std::function<waiting_out<Waiting, Running, Event>(waiting_signal_t const &)>;
    using running_handler_f = std::function<running_out<Waiting, Running, Event>(running_signal_t const &)>;

    void add_waiting(Waiting, waiting_handler_f);
    void add_running(Running, running_handler_f);

    void run(Event const &);

    state<Waiting, Running> const &current() const;

    bool contains(state<Waiting, Running> const &) const;

    static std::shared_ptr<graph> make_shared(Waiting);

   private:
    class impl;

    std::unique_ptr<impl> _impl;

    explicit graph(Waiting &&);
};
}  // namespace yas::flow

#include "flow_graph_private.h"
